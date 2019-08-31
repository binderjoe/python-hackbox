#!/bin/bash
set -euo pipefail

# Set authorized keys
mkdir -p ~/.ssh
echo $SSH_PUBLIC_KEY >> ~/.ssh/authorized_keys

# Update git config if GIT_USERNAME was set
if [[ ! -z $GIT_USERNAME ]]; then
    git config --global user.name "$GIT_USERNAME"
fi

# Pull git repo
git init
git remote add origin $REPO_URL
git pull origin $REPO_BRANCH
git push --set-upstream origin $REPO_BRANCH

# Pull secrets
az login --identity --allow-no-subscriptions
if [[ ! -z $KEY_VAULT ]]; then
    IFS=',' read -a secrets <<< "${KEY_VAULT_SECRETS}"
    for secret in "${secrets[@]}"
    do
        IFS=':' read -a parts <<< "${secret}"
        az keyvault secret download --vault-name $KEY_VAULT -n ${parts[0]} -f ${parts[1]}
    done
fi

# Set default sub
az account set -s $AZURE_SUBSCRIPTION_ID

# Start sshd
/usr/sbin/sshd -D