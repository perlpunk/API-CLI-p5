use strict;
use warnings;
package API::CLI::DigitalOcean;

use base 'API::CLI';

sub add_auth {
    my ($self, $client) = @_;
    my $cliconfig = $self->get_cliconfig;
    my $token = $cliconfig->{token};
    $client->addHeader('Authorization', "Bearer $token");
}

sub droplet_get_id_from_name_id {
    my ($self, $nameid) = @_;
    if ($nameid =~ m/--(\d+)$/) {
        return "$1";
    }
    elsif ($nameid =~ m/^(\d+)$/) {
        return $nameid;
    }
    else {
        die "invalid parameter nameid: '$nameid'";
    }
}


1;
