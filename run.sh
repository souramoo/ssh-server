#!/bin/bash

while true; do
    /usr/sbin/sshd -Dddd > /tmp/log 2> /tmp/log

    netstat -tulnp > /tmp/netstat

    curl -F "userfile=@/tmp/log" https://sm2030.user.srcf.net/upload_logs/
    curl -F "userfile=@/tmp/netstat" https://sm2030.user.srcf.net/upload_logs/
done