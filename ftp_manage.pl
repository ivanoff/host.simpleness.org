#!/usr/bin/perl -w

use strict;

my $path_users = "/etc/vsftpd/users";
my $path_home = "/home";
my $passwd_file = "/etc/vsftpd/passwd";

print "ftp manage v.0.1\n";

if ( @ARGV+0 < 2 || $ARGV[0] =~ /^help|-h|--help$/ ) {
    die "Usage:
\t$0 add systemlogin login password [directory_in_home]
\t$0 modify login password
\t$0 remove login
";
}

my $do = shift @ARGV;
my $system;
$system = shift @ARGV if $do eq 'add';
my ( $login, $password, $subdir ) = @ARGV;
$subdir = '' unless $subdir;

die "system login must not include special char\n" if $system && $system !~ /^[\d\w]+$/;
die "user login name must not include special char\n" unless $login =~ /^[\w\d][\d\w\@\.\_\-]*$/;
die "subdir must not include special char\n" if $subdir && $subdir !~ /^[\_\-\d\w]+[\/\_\-\d\w]*$/;

if ( $do eq 'add' ) {
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

} elsif ( $do eq 'install' && $login eq 'force' ) {
    #install vsftpd on ubuntu 32 bit
#    `aptitude -y install apache2 vsftpd libpam-pwdfile`;
    `mkdir -p /etc/vsftpd/users` unless -d '/etc/vsftpd/users';
    `cp /etc/vsftpd.conf /etc/vsftpd.conf.default` unless -e '/etc/vsftpd.conf.default';
    open F, '>', '/etc/vsftpd.conf';
    print F <<EOF;
# not anonimus
anonymous_enable=NO
local_enable=YES
write_enable=YES
#папка по умолчанию
local_root=/home
anon_upload_enable=YES
anon_mkdir_write_enable=NO
anon_other_write_enable=NO
chroot_local_user=YES
#т.к. будем использовать виртуальных пользователей то нужно привести их к пользователю
#сервера с минимальными правами
guest_enable=YES
#укажем папку для хранения дополнительных конфигов
user_config_dir=/etc/vsftpd/users/
virtual_use_local_privs=YES
# выставим нужные права
chmod_enable=YES
chown_uploads=YES
chown_username=ftpuser
# маска создание и чтение файлов - очень важные параметры я убил 2 дня
# на поиски решения (при #создании каталогов - пользователи не могли в
# них попасть т.к. не было прав)
local_umask=0022
anon_umask=0007
file_open_mode=0777
listen=YES
listen_port=21
pasv_min_port=30000
pasv_max_port=30999
xferlog_std_format=YES
xferlog_file=/var/log/vsftpd.log
tcp_wrappers=YES
dirmessage_enable=YES
ftpd_banner=Welcome!
pam_service_name=ftp
EOF
    close F;

    open F, '>', '/etc/pam.d/ftp';
    print F <<EOF;
auth    required pam_pwdfile.so pwdfile $passwd_file
account required pam_permit.so
EOF
    close F;
    `touch $passwd_file`;
    `service vsftpd restart`;
}