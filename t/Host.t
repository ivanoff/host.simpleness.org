#!/usr/bin/env perl -w

use Test::More tests => 10;

require_ok( 'Host' );
can_ok( 'Host', ( 'new', 'error', 'error_set', 'error_push', 'check_user', 'set_user_params', 'dir_owner', 'check_option', 'publish' ) );

my $host = new Host( );
isa_ok( $host, 'Host' );
isa_ok( $host->{template}, 'Template' );
print $host->{error};
ok( $host->{error} eq '', 'error is empty' );

ok( $host->error_set('123'), 'setting error');
ok( $host->error() eq '123', 'getting error');
ok( $host->error() eq $host->{error}, 'compare error var and error module');
ok( $host->error_push('abc'), 'pushing error');
ok( $host->error() eq "123\nabc", 'getting pushed error');
ok( $host->error_reset, 'resset error');
ok( $host->error() eq '', 'error is empty');
ok( $host->error_set('123'), 'setting error');
ok( $host->error_set, 'resset error via empty set');
ok( $host->error() eq '', 'error is empty');

ok( my @user = $host->check_user('root'), 'check root user in the system' );
ok( $user[0] eq 'root', 'we have root');
ok( $user[2] == 0, 'and he is root');

isnt( $host->check_user('root_BAD'), 1, 'root_BAD is not in the system' );

$host->{domain} = '';
$host->check_option( ['domain'] );
ok( $host->error eq 'domain name missing', 'domain name missing' );

$host->{subdomain} = '';
$host->check_option( ['subdomain'] );
ok( $host->error eq 'subdomain name missing', 'subdomain name missing' );

$host->{user} = '';
$host->check_option( ['user'] );
ok( $host->error eq 'user name missing', 'user name missing' );

$host->check_option( ['domain', 'user'] );
ok( $host->error eq "domain name missing\nuser name missing", 'user and domain names missing' );

$host->{domain} = '#$#$#$';
$host->check_option( ['domain'] );
ok( $host->error eq 'Domain name #$#$#$ contains wrong chars', 'Domain name contains wrong chars' );

$host->{subdomain} = '#$#$#$';
$host->check_option( ['subdomain'] );
ok( $host->error eq 'Subomain name #$#$#$ contains wrong chars', 'Subdomain name contains wrong chars' );

$host->{user} = '#$#$#$';
$host->check_option( ['user'] );
ok( $host->error eq 'User name contains wrong chars', 'User name contains wrong chars' );

$host->{user} = 'root_BAD';
$host->check_option( ['user'] );
ok( $host->error eq "User root_BAD don't exists", "User don't exist" );

$host->{domain} = 'ya.ua';
ok( $host->check_option( ['domain'] ), "Good domain" );

$host->{subdomain} = 'ya';
ok( $host->check_option( ['subdomain'] ), "Good subdomain" );

$host->{user} = 'root';
ok( $host->check_option( ['user'] ), "Good username" );
