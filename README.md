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
az keyvault secret create -n noelhackbox -g hackbox
az keyvault set-policy -n noelhackbox --object-id $PRINCIPAL_ID --secret-permissions 'get'
az keyvault secret set --vault-name noelhackbox -n foo --value bar
az keyvault secret set --vault-name noelhackbox -n baz --value secret

# Create an Azure Container Instance
SSHPUBLIC=`cat ~/.ssh/id_rsa.pub`
REPO_URL=https://github.com/noelbundick/python-hackbox.git
REPO_BRANCH=master
IDENTITY_ID=`az identity show -n hackbox -g hackbox --query id -o tsv`
KEY_VAULT=noelhackbox
KEY_VAULT_SECRETS="foo:foo.txt,bar:my_bar.txt"
AZURE_SUBSCRIPTION_ID=a9edaf6e-45e6-4879-b8fb-fb07d9b7104b

az container create -g hackbox -n hackbox --image acanthamoeba/hackbox:latest -e "REPO_URL=$REPO_URL" "REPO_BRANCH=$REPO_BRANCH" "SSH_PUBLIC_KEY=$SSHPUBLIC" "KEY_VAULT=$KEY_VAULT" "KEY_VAULT_SECRETS=$KEY_VAULT_SECRETS" "AZURE_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID" --ports 22 --dns-name-label noelhackbox --cpu 2 --memory 2 --assign-identity $IDENTITY_ID
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
