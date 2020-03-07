# Web app and remote access

## Build Status

[![Build Status](https://dev.azure.com/jannemattila/jannemattila/_apis/build/status/JanneMattila.327-webapp-remote-access?branchName=master)](https://dev.azure.com/jannemattila/jannemattila/_build/latest?definitionId=47&branchName=master)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Introduction

Containerized web app running in Azure App Service configured
so that you can remote to it using SSH.

You can connect via Web SSH Console e.g. 
_https://yoursitenamehere.scm.azurewebsites.net/webssh/host_

Or using `az` CLI:

```bash
# Create tunnel
az webapp create-remote-connection --name $appSvcName --resource-group $resourceGroup --port 9000
# Connect via tunnel
ssh root@localhost -p 9000
```

## Summary of changes to enable SSH in your custom container

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

And then change the entrypoint to be [custom script](https://github.com/JanneMattila/327-webapp-remote-access/blob/master/src/WebApp/Dockerfile#L51):

```dockerfile
ENTRYPOINT ["/bin/init_container.sh", "dotnet", "WebApp.dll"]
```

[Custom script](https://github.com/JanneMattila/327-webapp-remote-access/blob/master/init_container.sh#L25-L31) should start `ssh server` and then of course your application after that:

```bash
# ...
service ssh start

# Run the main application
$@
```

### How to deploy to App Service

Deploy published image to the Azure CLI way:

```batch
# Variables
appSvcName="mywebappremoteaccessdemo"
appSvcPlanName="webAppPlan"
resourceGroup="rg-webappremote-dev"
location="westeurope"
image="jannemattila/webapp-remote-access:1.0.14"

# Login to Azure
az login

# *Explicitly* select your working context
az account set --subscription <YourSubscriptionName>

# Create new resource group
az group create --name $resourceGroup --location $location

# Create App Service Plan
az appservice plan create --name $appSvcPlanName --resource-group $resourceGroup --is-linux --sku B1

# Create App Service
az webapp create --name $appSvcName --plan $appSvcPlanName --deployment-container-image-name $image --resource-group $resourceGroup

# Create SSH tunnel
az webapp create-remote-connection --name $appSvcName --resource-group $resourceGroup --port 9000

# Now you can connect via your SSH client using the tunnel
ssh root@localhost -p 9000

# Wipe out the resources
az group delete --name $resourceGroup -y
``` 

## Bonus content - CRON

This demo also show how you can use `cron` to run
some background tasks. 

Inside your `dockerfile` do [these changes](https://github.com/JanneMattila/327-webapp-remote-access/blob/master/src/WebApp/Dockerfile#L24-L28):

```dockerfile
# CRON Configuration->
RUN apt-get install -y --no-install-recommends cron
COPY mycron /etc/cron.d
RUN chmod 0744 /etc/cron.d/mycron
# <-CRON Configuration
```

[Custom script](https://github.com/JanneMattila/327-webapp-remote-access/blob/master/init_container.sh#L22-L23) should start `cron`:

```bash
echo Start CRON
service cron start
```

You can verify that `cron` is running by opening the web app
and then navigating to the `cron.txt` which is then
updated every minute by the background job.

## Links

[SSH support for Azure App Service on Linux](https://docs.microsoft.com/en-us/azure/app-service/containers/app-service-linux-ssh-support)
