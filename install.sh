#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
#This will install and start MySQL without so much as a peep until it is all done. 
#Of course you get a blank root password which is a security issue, but that is easy to fix later. 
#Piece of cake, if you happen to know about these magical exports.

apt-get -y update
apt-get -y upgrade

apt-get -y install gcc build-essential automake checkinstall
apt-get -y install imagemagick
apt-get -y install perlmagick libcrypt-ssleay-perl libnet-ssleay-perl
apt-get -y install libgd2-xpm-dev
apt-get -y install libssl-dev
apt-get -y install openssh-server

apt-get -y install subversion mc

apt-get -y install fail2ban
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
cp -f backup/etc/fail2ban/jail.local /etc/fail2ban/jail.local
sudo /etc/init.d/fail2ban restart

apt-get -y install bind9
cp -f backup/etc/bind/named.conf.options /etc/bind/named.conf.options
/etc/init.d/bind9 restart

apt-get -y install apache2 libapache2-svn apache2-mpm-itk
a2enmod rewrite
a2enmod expires
a2enmod ssl
mkdir /etc/apache2/ssl
/usr/sbin/make-ssl-cert /usr/share/ssl-cert/ssleay.cnf /etc/apache2/ssl/apache.pem
cp -f backup/etc/apache2/conf.d/vhosts.conf /etc/apache2/conf.d/vhosts.conf
/etc/init.d/apache2 restart

export DEBIAN_FRONTEND=noninteractive

apt-get -q -y install mysql-client-core-5.5
apt-get -q -y install mysql-server mysql-client php5-mysql libdbd-mysql-perl

apt-get -y install vsftpd libpam-pwdfile

apt-get -q -y install dovecot-common dovecot-imapd dovecot-pop3d
cp -f backup/etc/dovecot/dovecot.conf /etc/dovecot/dovecot.conf
touch /etc/dovecot/passwd
/etc/init.d/dovecot restart

apt-get -q -y install exim4-daemon-heavy
dpkg-reconfigure exim4-config
mkdir -p backup/etc/exim4/domains
mkdir -p backup/etc/exim4/virtual
mkdir -p backup/etc/exim4/userforward
cp -f backup/etc/exim4/authrelay /etc/exim4/authrelay
cp -f backup/etc/exim4/exim4.conf /etc/exim4/exim4.conf
cp -f backup/etc/exim4/postini_filtered /etc/exim4/postini_filtered
cp -f backup/etc/exim4/userdomains /etc/exim4/userdomains
cp -f backup/etc/exim4/virtual/exli.net /etc/exim4/virtual/exli.net
cp -f backup/etc/exim4/domains/exli.net /etc/exim4/domains/exli.net
/etc/init.d/exim4 restart

apt-get -y install quota quotatool
# vi /etc/fstab
# ...  ext3 defaults,errors=remount-ro,usrquota,grpquota 0 1
#touch /aquota.user /aquota.group
touch /home/quota.user /home/quota.group
chmod 600 /home/quota.*
mount -o remount /home
touch /quota.user /quota.group
chmod 600 /quota.*
mount -o remount /
quotacheck -avugm
#quotacheck -F vfsv0 -avum
quotaon -avug
#setquota -u user 100000 100000 0 0 -a
#quota -u rosya
# need to check

mkdir -p /etc/ssl/mycerts
cp -f backup/etc/ssl/mycerts/create_crt.sh /etc/ssl/mycerts/create_crt.sh
cd /etc/ssl/mycerts/ && ./create_crt.sh

#create database sirenko;
#create user 'sirenko'@'localhost' IDENTIFIED BY 'pass';
#GRANT ALL PRIVILEGES ON sirenko.* TO 'sirenko'@'localhost' WITH GRANT OPTION;

#apt-get -y install clamav clamav-base clamav-daemon
#freshclam
#usermod -aG Debian-exim clamav

# cacti stats
# https://www.digitalocean.com/community/articles/installing-the-cacti-server-monitor-on-ubuntu-12-04-cloud-server
#sudo apt-get install php5 php5-gd php5-mysql
#sudo apt-get install snmpd cacti cacti-spine

#CGI::Session
#Template
#DBD::Log

#sudo perl -MCPAN -e 'install GD'
#Time::HiRes
#Digest::MD5
#File::stat
#DBI
#force CGI
#Data::Dump
#LWP::Debug
#Image::Magick
#File::Copy
#REST::Google::Translate
#WWW::Mechanize
#Spreadsheet::Read
#Mail::Sendmail
#GD
#GD::SecurityImage
#RTF::Writer
#PDF::API2
#PDF::API2::Simple
#Image::Info
#Email::Send
#Email::Send::Gmail
#Email::Simple::Creator
#Net::SSLeay
