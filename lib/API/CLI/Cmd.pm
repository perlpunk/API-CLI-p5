package API::CLI::Cmd;
use strict;
use warnings;
use feature qw/ say /;
use base 'App::Spec::Run::Cmd';
use API::CLI::App::Spec;
use YAML::XS qw/ LoadFile DumpFile Dump /;

sub appspec_openapi {
    my ($self, $run) = @_;
    my $options = $run->options;
    my $parameters = $run->parameters;

    my $openapi_file = $parameters->{file};
    my $outfile = $options->{out};
    my $class = $options->{class} || 'API::CLI';
    my $name = $options->{name};

    my $openapi = LoadFile($openapi_file);

    my $appspec = API::CLI::App::Spec->openapi2appspec(
        openapi => $openapi,
        name => $name,
        class => $class,
    );
    if (defined $outfile) {
        DumpFile($outfile, $appspec);
        say "Wrote appspec to $outfile";
    }
    else {
        print Dump $appspec;
    }
}

1;
