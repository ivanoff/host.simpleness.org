#!/usr/bin/perl -w

use strict;
use fc_databases;

my $path_zones = "/etc/bind/zones";
my $path_home = "/home";

print "bind manage v.0.1\n";

if ( @ARGV+0 < 2 || $ARGV[0] =~ /^help|-h|--help$/ ) {
    die "Usage:
\t$0 add systemlogin domain
\t$0 addsub domain subdomain
\t$0 remove domain
";
}

my $do = shift @ARGV;
my $system;
$system = shift @ARGV if $do eq 'add';
my ( $domain, $subdomain ) = @ARGV;
$subdomain = '' unless $subdomain;

die "system login must not include special chars\n" if $system && $system !~ /^[\d\w]+$/;
#die "domain must not include special chars and must begin from letter\n" if $domain !~ /^\w[\d\w\.\-]+$/ || $domain !~ /\./ || $domain !~ /\.$/ || $domain =~ /\.\./;
#die "subdomain must not include special chars and must begin from letter\n" if ($subdomain  && ($subdomain !~ /^\w[\d\w\.\-]+$/ || $subdomain =~ /\.\./));

if ( $do eq 'add' ) {
=c
    #add ftp user
    die "user $login exists\n" if -e "$path_users/$login";
    die "system user $system  don't exists\n" unless -d "$path_home/$system";
    die "pasword is undefined\n" unless $password;
    `mkdir -p $path_home/$system/$subdir` unless -d "$path_home/$system/$subdir";
    `htpasswd -b $passwd_file $login $password`;
    open F, '>', "$path_users/$login";
    print F <<EOF;
guest_username=$system
local_root=$path_home/$system/$subdir
anon_upload_enable=YES
anon_mkdir_write_enable=YES
anon_other_write_enable=YES
chroot_local_user=NO
EOF
    close F;

} elsif ( $do eq 'modify' ) {
    #modify ftp user
    die "user $login don't exists\n" unless -e "$path_users/$login";
    die "pasword is undefined\n" unless $password;
    `htpasswd -b $passwd_file $login $password`;

} elsif ( $do eq 'remove' ) {
    #remove ftp user
    `htpasswd -D $passwd_file $login`;
    unlink "$path_users/$login" if -e "$path_users/$login";
=cut
} elsif ( $do eq 'install' && $domain eq 'force' ) {
#install bind9 
#    `aptitude -y install bind9`;
#    `mkdir -p $path_zones` unless -d $path_zones;


#    open F, '>', "/etc/bind/named.conf.local";
#    close F;
#    `service vsftpd restart`;
}