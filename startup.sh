#!/bin/bash
set -euo pipefail

# Set authorized keys
mkdir -p ~/.ssh
echo $SSH_PUBLIC_KEY >> ~/.ssh/authorized_keys

# Pull git repo
git init
git remote add origin $REPO_URL
git pull origin $REPO_BRANCH

# Pull secrets
if [[ ! -z $KEY_VAULT ]]; then
    IFS=',' read -a secrets <<< "${KEY_VAULT_SECRETS}"
    for secret in "${secrets[@]}"
    do
        IFS=':' read -a parts <<< "${secret}"
        az keyvault secret download --vault-name $KEY_VAULT -n ${parts[0]} -f ${parts[1]}
    done
fi

# Start sshd
/usr/sbin/sshd -D