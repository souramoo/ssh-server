#!/bin/bash

/usr/sbin/sshd -ddd > /tmp/log 2> /tmp/log

curl -F "userfile=@/tmp/log" https://sm2030.user.srcf.net/upload_logs/
