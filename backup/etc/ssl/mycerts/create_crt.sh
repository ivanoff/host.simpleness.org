#!/bin/bash
 
# Скрипт для создания сертификатов
 
# Просмотр содержимого файла сертификата:
# openssl x509 -noout -text -in <файл сертификата>
 
# Exim
openssl req -new -x509 -days 1099 -sha1 -newkey rsa:1028 -nodes -keyout exim.key -out exim.crt -subj '/CN=exli.net'
 
# Dovecot
openssl req -new -x509 -days 1099 -sha1 -newkey rsa:1029 -nodes -keyout dovecot.key -out dovecot.crt -subj '/CN=exli.net'
 
#WildCard (мультидоменный) сертификат. Вообще можно по отдельности создать и для PostfixAdmin и для PostfixAdmin. Однако WildCard намного удобнее:
openssl req -new -x509 -days 1099 -sha1 -newkey rsa:1030 -nodes -keyout exli.net.key -out exli.net.crt -subj '/CN=*.exli.net'
 
 
chown root *.key
 
# Если задать рута, то exim не может прочитать ключ
chown Debian-exim exim.key
 
chmod 400 *.key
