# ABSTRACT: lala
use strict;
use warnings;
package API::CLI;
use 5.010;

use JSON::Syck ();
use YAML::XS ();
use JSON ();
use REST::Client;
use Text::Table;
use File::Temp;
use Term::ReadKey qw/ GetTerminalSize /;
use List::Util qw/ max /;
use URI::Escape qw/ uri_escape /;
use App::Spec;
use base 'App::Spec::Run';

use Moo;
has config_file => (is => 'ro');
has api_spec_file => (is => 'ro');
has api_spec => (is => 'rw');
has config => (is => 'rw');
has dir => (is => 'rw');
has spec => (is => 'rw');

sub BUILD {
    my ($self) = @_;
    my $file = $self->api_spec_file;
    my $api_spec = YAML::XS::LoadFile($file);
    $self->api_spec($api_spec);

    my $config_file = $self->config_file;
    my $config = YAML::XS::LoadFile($config_file);
    $self->config($config);

    my $paths = $api_spec->{paths};
    for my $path (sort keys %$paths) {
        my $methods = delete $paths->{ $path };
        $path =~ s/\{(\w+)\}/:$1/g;
        $paths->{ $path } = $methods;
    }

    my $appspec = $self->spec;
    my $data = YAML::XS::Load($appspec);

    my $commands = $data->{subcommands} ||= {};
    my %methods;
    my $config_paths = $self->config->{paths};
    for my $path (keys %$paths) {
        my $methods = $paths->{ $path };
        for my $method (keys %$methods) {
            my $def = $methods->{ $method };
            my $summary = $def->{description};
            $summary =~ s/\n.*//s;
            my $formats = $config_paths->{ $path }->{ $method }->{output}->{formats};
            $commands->{ uc $method } ||= {
                summary => "$method request",
                op => "cmd_request",
            };
            my @options = grep { $_->{in} eq "query" } @{ $def->{parameters} };
            @options = map {
                my %opt = %$_;
                my $summary = $opt{description} // '';
                $summary =~ s/\n.*//s;
                $opt{description} = $summary;
                $opt{name} = "param-$opt{name}";
                if (my $enum = delete $opt{enum}) {
                    $opt{type} = { enum => $enum };
                }
                \%opt
            } @options;
            if ($formats) {
                push @options, {
                    name => "format",
                    type => {
                        enum => [sort keys %$formats],
                    },
                };
            }
            my @parameters = grep { $_->{in} eq "path" } @{ $def->{parameters} };
            $commands->{ uc $method }->{subcommands}->{ $path } = {
                summary => $summary,
                parameters => \@parameters,
                options => \@options,
            };
        }
    }

    {
        my $config_commands = $self->config->{subcommands};
        my $filtered = $self->config_commands_to_appspec($config_commands);
        %$commands = (%$commands, %$filtered);
    }

    $appspec = App::Spec->read($data);
    $self->spec($appspec);

    return $self;
}

sub config_commands_to_appspec {
    my ($self, $commands) = @_;
    my $result = {};
    for my $name (keys %$commands) {
        my $cmd_spec = $commands->{ $name };
        my $subc = $cmd_spec->{subcommands};
        $subc = $self->config_commands_to_appspec($subc);
        $result->{ $name } = {
            name => $name,
            op => $cmd_spec->{op},
            summary => $cmd_spec->{summary},
            subcommands => $subc,
            parameters => $cmd_spec->{parameters},
            options => $cmd_spec->{options},
        };
    }
    return $result;
}

sub cmd_apicalls {
    my ($self) = @_;
    my $config = $self->config;
    my $config_commands = $config->{subcommands};
    my $commands = $self->commands;
    my $cmd_spec;
    for my $cmd (@$commands) {
        $cmd_spec = $config_commands->{ $cmd };
        $config_commands = $cmd_spec->{subcommands};
    }
    my $call = $cmd_spec->{call}->{arguments};
    my $method = $cmd_spec->{call}->{method};
    warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\$method], ['method']);
    if ($method) {
        $self->$method;
    }
    else {
        warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\$call], ['call']);
        my @args;
        for my $arg (@$call) {
            if (ref $arg) {
                my $name = $arg->{parameter};
                my $value = $self->parameters->{ $name };
                push @args, $value;
            }
            else {
                push @args, $arg;
            }
        }
        warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\@args], ['args']);
        system($self->spec->name, @args);
    }
#    $self->exec_command($cmd, $path, @args);
}

sub cmd_request {
    my ($self) = @_;
#    warn __PACKAGE__.':'.__LINE__.": REQUEST\n";
    my $parameters = $self->parameters;
#    warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\$parameters], ['parameters']);
    my $commands = $self->commands;
#    warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\$commands], ['commands']);
    my ($cmd, @args) = @$commands;
    $self->exec_command($cmd, @args);
}

sub exec_command {
    my ($self, $cmd, $path) = @_;
    my $options = $self->options;
    my $paths = $self->api_spec->{paths};
    my $path_prefix = $self->api_spec->{basePath};
    #    warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\@args], ['args']);
    my ($matched_path) = $self->find_matching_paths($cmd, $path);
    my $info = $paths->{ $matched_path }->{ lc $cmd };
    my $parameters = $info->{parameters};
    my @query_parameters = grep { $_->{in} eq "query" } @$parameters;
    my $param = $self->parameters;
#    warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\$param], ['param']);
    my @path_parameters = grep { $_->{in} eq "path" } @$parameters;
    for my $pp (@path_parameters) {
        my $name = $pp->{name};
        my $value = $param->{ $name };
        $path =~ s/:$name/$value/g;
        warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\$path], ['path']);
    }

    my $qs = "";
    for my $opt (sort keys %$options) {
        my $value = $options->{ $opt } or next;
        $value = uri_escape($value);
        if ($opt =~ s/^param-//) {
            $qs .= "$opt=$value;";
        }
    }
    if (length $qs) {
        $path .= "?$qs";
    }
    my @body_parameters = grep { $_->{in} eq "body" } @$parameters;
    my $body;
    if (@body_parameters) {
        my $fh = File::Temp->new();
        my $fname = $fh->filename;
        my $data;
        for my $param (@body_parameters) {
            my $name = $param->{name};
            my $type = $param->{type};
            my $default = '';
            if (ref $type and $type->{enum}) {
                $default = $type->{enum}->[0];
            }
            elsif ($type eq "bool") {
                $default = JSON::false;
            }
           $data->{ $name } = $default; #$param->{description};
        }
        my $json = JSON::to_json( $data, { ascii => 1, pretty => 1 } );
        print $fh $json;
        say $fname if $options->{debug};
        say $json if $options->{debug};
        close $fh;
        system($ENV{EDITOR} // 'vim', $fname);
        open $fh, "<", $fname;
        $body = do { local $/; <$fh> };
        close $fh;
    }
    if ($path_prefix) {
        $path = $path_prefix . $path;
    }
    say "REQUEST: $path" if $options->{debug};
#    say "BODY: $body" if $body and $options->{debug};
    if ($options->{dryrun}) {
        say "dryrun, exiting";
        exit;
    }

    my $client = $self->create_client;
    my $res = $client->$cmd($path, $body);

    my $content = $client->responseContent;
#    warn __PACKAGE__.':'.__LINE__.": $content\n" if $options->{debug};
    my $data = JSON::Syck::Load($content);
    if ($options->{yaml}) {
        my $dump = YAML::XS::Dump($data);
        say $dump;
    }
    elsif ($options->{table} or $options->{format}) {
        my $config = $self->config->{paths}->{ $matched_path }->{ lc $cmd };
        my $output = $config->{output};
        if ($output->{type} eq "item" or $output->{type} eq "listitem" and not $options->{format}) {
            my $def = $output->{item};
            my $prefix = $def->{prefix} // '';
            my $fields = $def->{fields};
            my $output_data = $data;
            if ($prefix) {
                $output_data = $output_data->{ $prefix };
            }
            my %labels = map {
                my $f = $_;
                my $label = $self->make_label($f);
                $f => $label
            } @$fields;
            my $tb = Text::Table->new();
            my @rows;
            for my $field (@$fields) {
                my ($value) = $self->get_fields($output_data, [$field]);
                next unless defined $value;
                my @row = ($labels{ $field }, $value);
                push @rows, \@row;
            }
            $tb->load(@rows);
            say $tb;
        }
        if ($output->{type} eq "list" or $output->{type} eq "listitem") {
            my $def;
#            warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\$options], ['options']);
            if ($options->{table}) {
                $def = $output->{table};
            }
            elsif ($options->{format}) {
                $def = $output->{formats}->{ $options->{format} }
                    or die "Format $options->{format} not found";
#                    warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\$def], ['def']);
            }
            my $prefix = $def->{prefix} // '';
            my $output_data = $data;
            if ($prefix) {
                $output_data = $output_data->{ $prefix };
            }
#            warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\$output_data], ['output_data']);
            my $fields = $def->{fields};

            my @rows;
            for my $item (@$output_data) {
                my @row = $self->get_fields($item, $fields);
                push @rows, \@row;
            }

            if ($options->{table}) {
                my %labels = map {
                    my $f = $_;
                    my $label = $self->make_label($f);
                    $f => $label
                } @$fields;
                my $tb = Text::Table->new(
                   @labels{ @$fields }
                );
                $tb->load(@rows);
                say $tb;
            }
            elsif ($options->{format}) {
                my $format_string = $def->{format};
                for my $row (@rows) {
                    printf "$format_string\n", @$row;
                }
            }
        }
    }
    else {
        say $content;
    }

}

sub create_client {
    my ($self) = @_;
    my $host = $self->api_spec->{host};
    my $schemes = $self->api_spec->{schemes};
    $host = "$schemes->[0]://$host";
    say "HOST: $host" if $self->options->{debug};
    my $client = REST::Client->new({
            host    => $host,
            timeout => 10,
        });
    my $ct = 'application/json';

    $client->addHeader('Accept', $ct);
    $self->add_auth($client);
    return $client;
}

sub add_auth {
    my ($self, $client) = @_;
#    my $cliconfig = $self->get_cliconfig;
#    my $token = $cliconfig->{token};
#    $client->addHeader('Authorization', "token $token");
}

sub get_cliconfig {
    my ($self) = @_;
    my $dir = $self->dir;
    my $cliconfig = YAML::XS::LoadFile("$dir/config.yaml");
}

sub make_label {
    my ($self, $field) = @_;
    my $label = join ' ', map { ucfirst } split m{[_/]}, $field;
    return $label;
}

sub get_fields {
    my ($self, $data, $fields) = @_;
    my @result;
    for my $field (@$fields) {
        my @parts = split m{/}, $field;
        @parts = map {
            my @p;
            if (s/^([^\[]+)//) {
                push @p, "$1";
            }
            while (s/^\[(\d+)\]//) {
                push @p, \"$1";
            }
            @p;
        } @parts;
        my $value = $data;
        for my $part (@parts) {
            if (ref $part) {
                $value = $value->[ $$part ];
            }
            else {
                $value = $value->{ $part };
            }
        }
        push @result, $value;
    }
    return @result;
}

sub print_paths {
    my ($self) = @_;
    my $paths = $self->api_spec->{paths};
    my $tb = Text::Table->new(
        qw/ Method Path Description /
    );
    my @rows;
    warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\$paths], ['paths']);
    for my $path (sort keys %$paths) {
        my $methods = $paths->{ $path };
        for my $method (sort keys %$methods) {
            push @rows, [uc $method, $path, $methods->{ $method }->{description}];
        }
    }
    $tb->load(@rows);
    my ($wchar, $hchar) = GetTerminalSize();
    my $width = $tb->width;
    if ($width > $wchar) {
        my $diff = $width - $wchar;
        my $max = max map { length $_->[2] } @rows;
        my $length_to_cut = $max - $diff - 3;
        for my $row (@rows) {
            if (length $row->[2] > $length_to_cut) {
                substr($row->[2], $length_to_cut, length $row->[2], '...');
            }
        }
        $tb->clear;
        $tb->load(@rows);
    }
    print $tb;
}

sub find_matching_paths {
    my ($self, $meth, $path) = @_;
    my $paths = $self->api_spec->{paths};
    my @possible_paths;
    for my $p (sort keys %$paths) {
        my @p = split m{/}, $p;
        for (@p) {
            s{^:\w+$}{.*?}
        }
        my $regex = join '/', @p;
        if ($path =~ qr{^$regex}) {
            push @possible_paths, $p;
        }
    }
    return sort { length($b) <=> length($a) } @possible_paths;
}
1;
