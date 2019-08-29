#!/bin/bash
set -euo pipefail

mkdir -p ~/.ssh
echo $SSH_PUBLIC_KEY >> ~/.ssh/authorized_keys

# Pull git repo
git init
git remote add origin $REPO_URL
git pull origin $REPO_BRANCH

# Start sshd
/usr/sbin/sshd -D