use strict;
use warnings;
package API::CLI::Github;

use base 'API::CLI';

sub add_auth {
    my ($self, $client) = @_;
    my $cliconfig = $self->get_cliconfig;
    my $token = $cliconfig->{token};
    $client->addHeader('Authorization', "Bearer $token");
}

sub repo_get_repo_from {
    my ($self, $owner_repo) = @_;
    my ($owner, $repo) = split m#/#, $owner_repo;
    return $repo;
}

sub search_user_repos {
    my ($self) = @_;
    my $options = $self->options;
    my $parameters = $self->parameters;
    my $user = $parameters->{user};
    my $q = $parameters->{q};
    my $fork = $options->{fork};
    my $in = $options->{in};
    my $count = $options->{count};
    my @args = (
        "GET", "/search/repositories",
        "--param-q", "in:$in user:$user fork:$fork $q",
        "--format", "name",
        "--param-per_page", $count,
    );
    system($self->spec->name, @args);
}

sub search_users {
    my ($self) = @_;
    my $options = $self->options;
    my $parameters = $self->parameters;
    my $q = $parameters->{q};
    warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\$options], ['options']);
    my $in = $options->{in};
    my @args = ("GET", "/search/users", "--param-q", "in:$in $q", "--format", "login", "--param-per_page", $options->{count});
    warn __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\@args], ['args']);
    system($self->spec->name, @args);
}


1;
