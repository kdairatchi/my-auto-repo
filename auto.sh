#!/usr/bin/env bash

# Configuration
REPO_NAME="my-new-repo"
DESCRIPTION="This is my new repository created with gh."
VISIBILITY="public" # Can be public or private

# Step 1: Create a new GitHub repository
gh repo create "$REPO_NAME" --$VISIBILITY --description "$DESCRIPTION" --source . --remote origin --push
echo "[+] Repository '$REPO_NAME' created and pushed to GitHub."

# Step 2: Open the repository in the browser
gh repo view --web
