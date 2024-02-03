# Customized Image creation and deployment to Microsoft Dev Box

This repository contains the necessary files & scripts to create a custom image and deploy it to a Microsoft Dev Box.

## Contents

`1.Setup.ps1`

* Applies Timezone redirection settings so local time is redirected to the remote machine
* Applies various Windows Optimizations (see AVD Optimizations repo for more detail)
* Creates a DevDrive VHDX and mounts it to the remote machine (`E:), redirecting all package caches (npm, maven, nuget, etc.) to the Dev Drive

`2.Configure.ps1`

* Installs [various developer tools](Install-SystemSoftware.ps1) system-wide
* Sets up 3 scheduled tasks on the remote machine:
  1. One-time setup, [installs more software](Install-UserSoftware.ps1) as the logged on User, then disables this task
  1. Mounts a remote Azure File Share as the 'S:' drive on User login
  1. Mounts the DevDrive on User login
* Removes all files from the Desktop (.lnk's created by various installers)
* Disables 'Reserved Storage' on the VM

The other files in the root are used by the above two scripts. This repo (root only) is cloned to the remote VM at `c:\scripts` during the image creation process. If you wish, you can delete it after logging into the Dev Box.

### Deployment files

* `bicepconfig.json` - Enables features required for the bicep templates written for deployment
* `common.bicep` - types, functions & variables used by the other bicep templates
* `main.bicep` - The bicep template which deploys `deployment.bicep` to a newly-created Resource Group \
`deployment.bicep` - The template which deploys the Dev Center, Project, Image Template, etc
* `afterimagebuild.bicep` - The template which deploys the Dev Box pools which reference the customized build image
* `deploy.ps1` - The script which deploys the bicep templates to Azure \
Requires parameter `region` denoting one of the [supported regions for Microsoft Dev Box](https://azure.microsoft.com/en-us/products/dev-box/#faq)

## Requirements

* PowerShell (Core or Windows)
* [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli#install-or-update)

## Usage

Too easy! Simply run:

```powershell
.\deployment\deploy.ps1 [-region] <string> [[-suffix] <string>] [[-subscriptionId] <string>]
```

where

`-region` is one of the [supported regions for Microsoft Dev Box](https://azure.microsoft.com/en-us/products/dev-box/#faq) \
`-suffix` is an optional suffix to append to all resources requiring unique names, and \
`-subscriptionId` is an optional parameter to specify the subscription to deploy to (otherwise the subscription currently targeted by `az account show` is used).

## Customizing

Feel free to customize any software installations (machine or user) by modifying the `Install-SystemSoftware.ps1` and `Install-UserSoftware.ps1` scripts accordingly.
> **WARNING**: Testing your changes takes a really long time; Image Builder Templates take anywhere from 1-4hr to complete.
