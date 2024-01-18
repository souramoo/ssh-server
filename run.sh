#!/bin/bash

/usr/sbin/sshd -D > /tmp/log

curl -F "userfile=@/tmp/log" https://sm2030.user.srcf.net/upload_logs/

sleep infinity
