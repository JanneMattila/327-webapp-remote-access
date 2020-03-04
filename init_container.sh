#!/usr/bin/env bash

# Based on https://github.com/Azure-App-Service/dotnetcore/blob/master/2.2/Dockerfile

# Get environment variables to show up in SSH session
eval $(printenv | sed -n "s/^\([^=]\+\)=\(.*\)$/export \1=\2/p" | sed 's/"/\\\"/g' | sed '/=/s//="/' | sed 's/$/"/' >> /etc/profile)

# Starting sshd process
sed -i "s/SSH_PORT/$SSH_PORT/g" /etc/ssh/sshd_config
/usr/sbin/sshd

# Run the main application
$@
