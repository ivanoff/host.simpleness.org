#!/bin/bash

CREATE DATABASE host;
CREATE USER `host_master`@`localhost` IDENTIFIED BY `host_master_password`;
GRANT ALL PRIVILEGES ON `host\_%`.* TO `host_master`@`localhost` WITH GRANT OPTION;
FLUSH PRIVILEGES;
