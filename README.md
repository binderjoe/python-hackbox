# python-hackbox

This is a Python dev container meant to be run on Azure Container Instances

## Features

* Dependencies pre-pulled into the image in a virtual environment
* Azure CLI + Managed Identity w/ automatic login
* Configured for VS Code SSH Remote Development
* Clones a repo on startup

## Usage

One-time steps

```bash
# Build a container with your dependencies that should be baked in
docker build --build-arg REQ=https://raw.githubusercontent.com/noelbundick/python-hackbox/master/requirements.txt

# Push to Docker Hub
docker push acanthamoeba/hackbox

# Set up some one-time Azure resources
az group create -n hackbox -l westus
az identity create -n hackbox -g hackbox
PRINCIPAL_ID=`az identity show -n hackbox -g hackbox --query principalId -o tsv`
az role assignment create --role Contributor --assignee $PRINCIPAL_ID

# Create an Azure Container Instance
SSHPUBLIC=`cat ~/.ssh/id_rsa.pub`
REPO_URL=https://github.com/noelbundick/python-hackbox.git
REPO_BRANCH=master
IDENTITY_ID=`az identity show -n hackbox -g hackbox --query id -o tsv`

az container create -g hackbox -n hackbox --image acanthamoeba/hackbox:latest -e "REPO_URL=$REPO_URL" "REPO_BRANCH=$REPO_BRANCH" "SSH_PUBLIC_KEY=$SSHPUBLIC" --ports 22 --dns-name-label noelhackbox --cpu 2 --memory 2 --assign-identity $IDENTITY_ID
```

In Visual Studio Code:

* Install [Visual Studio Code](https://code.visualstudio.com)
* Get the [Remote Development Extension Pack](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack)

Add an entry to your SSH config

```
Host hackbox
    User root
    HostName noelhackbox.westus2.azurecontainer.io
    IdentityFile C:\users\noel\.ssh\id_rsa
```
