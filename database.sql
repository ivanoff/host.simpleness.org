CREATE DATABASE fp_exli_net;
CREATE USER 'fp_exli_net'@'localhost' IDENTIFIED BY 'fp_exli_net';
GRANT ALL ON fp_exli_net.* TO 'fp_exli_net'@'localhost';
FLUSH PRIVILEGES;

