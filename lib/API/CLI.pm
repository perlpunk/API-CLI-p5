use strict;
use warnings;
use 5.010;
package API::CLI;

use base 'App::Spec::Run::Cmd';

use URI;
use YAML::XS ();
use LWP::UserAgent;
use HTTP::Request;
use App::Spec;
use JSON::XS;
use API::CLI::Request;

use Moo;

has dir => ( is => 'ro' );
has openapi => ( is => 'ro' );

sub add_auth {
    my ($self, $req) = @_;
    my $appconfig = $self->read_appconfig;
    my $token = $appconfig->{token};
    $req->header(Authorization => "Bearer $token");
}

sub read_appconfig {
    my ($self) = @_;
    my $dir = $self->dir;
    my $appconfig = YAML::XS::LoadFile("$dir/config.yaml");
}

sub apicall {
    my ($self, $run) = @_;
    my ($method, $path) = @{ $run->commands };
    my $params = $run->parameters;
    my $opt = $run->options;
    if ($opt->{debug}) {
        warn __PACKAGE__.':'.__LINE__.": apicall($method $path)\n";
        warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\$params], ['params']);
        warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\$opt], ['opt']);
    }
    $path =~ s{(?::(\w+)|\{(\w+)\})}{$params->{ $1 // $2 }}g;
    if ($opt->{debug}) {
        warn __PACKAGE__.':'.__LINE__.": apicall($method $path)\n";
    }

    my $REQ = API::CLI::Request->from_openapi(
        openapi => $run->spec->openapi,
        method => $method,
        path => $path,
        options => $opt,
        parameters => $params,
        verbose => $opt->{verbose} ? 1 : 0,
    );

    $self->add_auth($REQ);

    if ($method =~ m/^(POST|PUT|PATCH|DELETE)$/) {
        my $data_file = $opt->{'data-file'};
        if (defined $data_file) {
            open my $fh, '<', $data_file or die "Could not open '$data_file': $!";
            my $data = do { local $/; <$fh> };
            close $fh;
            $REQ->content($data);
        }
    }

    my ($ok, $out, $content) = $REQ->request;
    if (defined $out) {
        unless ($ok) {
            $out = $run->error($out);
        }
        warn $out;
    }
    say $content;

}

1;

