# Web app and remote access

## Build Status

[![Build Status](https://dev.azure.com/jannemattila/jannemattila/_apis/build/status/JanneMattila.327-webapp-remote-access?branchName=master)](https://dev.azure.com/jannemattila/jannemattila/_build/latest?definitionId=47&branchName=master)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Introduction

Containerized web app that has SSH configuration done so that you can remote to it from Azure App Service.

How to connect: 

```bash
az webapp create-remote-connection -g $resourceGroup -n $app -p 9000
```

## Links

[SSH support for Azure App Service on Linux](https://docs.microsoft.com/en-us/azure/app-service/containers/app-service-linux-ssh-support)
