# Web app and remote access

## Build Status

[![Build Status](https://dev.azure.com/jannemattila/jannemattila/_apis/build/status/JanneMattila.327-webapp-remote-access?branchName=master)](https://dev.azure.com/jannemattila/jannemattila/_build/latest?definitionId=47&branchName=master)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Introduction

Containerized web app that has SSH configuration done so that you can remote to it from Azure App Service.

You can connect via Web SSH Console e.g. 
_https://yoursitenamehere.scm.azurewebsites.net/webssh/host_
or using `az` CLI:

```bash
az webapp create-remote-connection -g $resourceGroup -n $app -p 9000
```

## Summary of changes to enable SSH

Inside your `dockerfile` do [these changes](https://github.com/JanneMattila/327-webapp-remote-access/blob/master/src/WebApp/Dockerfile#L9-L22):

```dockerfile
# SSH Configuration->
EXPOSE 2222
ENV SSH_PORT 2222
RUN apt-get update -qq && \
    apt-get dist-upgrade --no-install-recommends -y && \
    apt-get install -y --no-install-recommends openssh-server && \
    echo "root:Docker!" | chpasswd

COPY init_container.sh /bin/
RUN chmod 755 /bin/init_container.sh

COPY sshd_config /etc/ssh/
RUN mkdir -p /var/run/sshd
# <-SSH Configuration
```

And then change the entrypoint to be [custom script](https://github.com/JanneMattila/327-webapp-remote-access/blob/master/src/WebApp/Dockerfile#L45):

```dockerfile
ENTRYPOINT ["/bin/init_container.sh", "dotnet", "WebApp.dll"]
```

[Custom script](https://github.com/JanneMattila/327-webapp-remote-access/blob/master/init_container.sh#L24-L31) should start `ssh server` and then of course your application after that:

```bash
# ...
/usr/sbin/sshd

# Run the main application
$@
```

## Links

[SSH support for Azure App Service on Linux](https://docs.microsoft.com/en-us/azure/app-service/containers/app-service-linux-ssh-support)
