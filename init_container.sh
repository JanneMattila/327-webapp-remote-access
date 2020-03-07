#!/usr/bin/env bash
# Based on https://github.com/Azure-App-Service/dotnetcore/blob/master/2.2/Dockerfile

cat >/etc/motd <<EOL 
     _
    | | __ _ _ __  _ __   ___
 _  | |/ _` | '_ \| '_ \ / _ \
| |_| | (_| | | | | | | |  __/
 \___/ \__,_|_| |_|_| |_|\___|
 App Service remote access using SSH

GitHub: https://github.com/JanneMattila/327-webapp-remote-access
Docker Hub: https://hub.docker.com/r/jannemattila/webapp-remote-access

.NETCore runtime version: `ls -X /usr/share/dotnet/shared/Microsoft.NETCore.App | tail -n 1`
EOL
cat /etc/motd

# Get environment variables to show up in SSH session
eval $(printenv | sed -n "s/^\([^=]\+\)=\(.*\)$/export \1=\2/p" | sed 's/"/\\\"/g' | sed '/=/s//="/' | sed 's/$/"/' >> /etc/profile)

# Starting sshd process
echo Modifying ssh server configuration with: $SSH_PORT
sed -i "s/SSH_PORT/$SSH_PORT/g" /etc/ssh/sshd_config
cat /etc/ssh/sshd_config

echo Start CRON
service cron start

echo Start sshd
service ssh start

# Run the main application
$@
