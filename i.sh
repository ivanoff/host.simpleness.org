#!/bin/bash

echo "Simpleness Host installer"
echo "more info at: http://host.simpleness.org"

if [ "$(id -u)" != "0" ]; then
    echo "Need sudo user rights. Please, run 'sudo $0'"
    exit 1
fi

read -p "Do you want to continue [Y/n]? " REPLY

if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ ! $REPLY = "" ]]
then
    exit 1;
fi


# ask mysql password
echo "New mysql root password: "
read password1
echo "Re-enter new password: $echo_c"
read password2

if [ "$password1" != "$password2" ]; then
echo "Sorry, passwords do not match."
echo
return 1
fi

if [ "$password1" = "" ]; then
echo "Sorry, you can't use an empty password here."
echo
return 1
fi 


export DEBIAN_FRONTEND=noninteractive
# This will install and start MySQL without so much as a peep until it is all done..
# Of course you get a blank root password which is a security issue, but that is easy to fix later..
# Piece of cake, if you happen to know about these magical exports.


echo "[INFO] update and install modules"
apt-get -y update
apt-get -y upgrade

apt-get -y install gcc build-essential automake checkinstall
apt-get -y install libgd2-xpm-dev
apt-get -y install libcrypt-ssleay-perl libnet-ssleay-perl libssl-dev
apt-get -y install openssh-server
apt-get -y install subversion mc
apt-get -y install bind9
apt-get -y install apache2 libapache2-svn apache2-mpm-itk
apt-get -y -q install mysql-client-core-5.5
apt-get -y -q install mysql-server mysql-client php5-mysql libdbd-mysql-perl
apt-get -y -q install dovecot-common dovecot-imapd dovecot-pop3d
apt-get -y install vsftpd libpam-pwdfile
apt-get -y install quota quotatool
apt-get -y install fail2ban


echo "[INFO] install perl modules"
# perl image magic
# Getopt::Long File::Path IO::All DBI WWW::Mechanize WWW::Mechanize::GZip
# CGI CGI::Session Template Encode Text::Diff Email::Send Email::MIME::Creator
# Shell::Command
apt-get -y install imagemagick perlmagick
apt-get -y install libgetopt-lucid-perl libio-all-perl libdbi-perl libdbd-mysql-perl  libdbd-pg-perl libwww-mechanize-perl libwww-mechanize-gzip-perl
apt-get -y install libcgi-pm-perl libcgi-session-perl libtemplate-perl libencode-perl libtext-diff-perl libemail-send-perl libemail-mime-creator-perl
apt-get -y install libshell-command-perl

# The following packages have unmet dependencies: perl-modules : Breaks: libfile-path-perl (< 2.08.01)
# let's try?
#sudo apt-get -y install cpanminus
# installed
#sudo cpan Digest::MD5
#sudo cpan Time::HiRes
# is part of the perl-5.17.4 distribution
#sudo cpan File::Copy
#sudo cpan utf8
#sudo cpan POSIX


# Remove anonymous users,  Remove remote root, Dropping test database
# Removing privileges on test database, Change root password
mysql -u root -e "DELETE FROM mysql.user WHERE User='';"
mysql -u root -e "DROP DATABASE test;"
mysql -u root -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'"
mysql -u root -e "DELETE FROM mysql.user WHERE User='root' AND Host!='localhost';"
mysql -u root -e "UPDATE mysql.user SET Password=PASSWORD('$password1') WHERE User='root';FLUSH PRIVILEGES;"

mkdir -p /opt/host/conf
echo
echo "MYSQL_PASSWORD=$password1" >> /opt/host/conf/host.conf
