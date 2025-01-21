#!/usr/bin/env bash

# ---------------------------
# Configuration
# ---------------------------
REPO_NAME="my-repo"
REPO_DESC="Automated GitHub repository setup with gh"
VISIBILITY="private"  # Options: public or private
DEFAULT_BRANCH="main"

# ---------------------------
# Functions
# ---------------------------

# Log messages
log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Create a new repository
create_repo() {
  if gh repo view "$REPO_NAME" >/dev/null 2>&1; then
    log "[+] Repository '$REPO_NAME' already exists on GitHub."
  else
    gh repo create "$REPO_NAME" --$VISIBILITY --description "$REPO_DESC" --source . --remote origin --push
    log "[+] Repository '$REPO_NAME' created and pushed to GitHub."
  fi
}

# Clone the repository
clone_repo() {
  if [ -d "$REPO_NAME" ]; then
    log "[+] Repository '$REPO_NAME' is already cloned locally."
  else
    gh repo clone "$REPO_NAME"
    log "[+] Cloned repository '$REPO_NAME'."
  fi
}

# Add a .gitignore file
create_gitignore() {
  if [ ! -f "$REPO_NAME/.gitignore" ]; then
    cat <<EOF > "$REPO_NAME/.gitignore"
# Ignore backups and logs
*.bak
*.log
backups/
logs/

# Ignore node_modules
node_modules/

# Ignore environment files
.env
EOF
    log "[+] Created .gitignore file in '$REPO_NAME'."
  fi
}

# Commit and push changes
commit_and_push() {
  cd "$REPO_NAME" || exit
  git add .
  git commit -m "Automated initial setup" || log "[-] Nothing to commit."
  git push origin "$DEFAULT_BRANCH" || log "[-] Failed to push changes."
  cd ..
}

# Create a GitHub issue
create_issue() {
  ISSUE_TITLE="Setup Verification"
  ISSUE_BODY="Verify that the repository setup is complete."
  gh issue create --title "$ISSUE_TITLE" --body "$ISSUE_BODY"
  log "[+] Created issue: $ISSUE_TITLE."
}

# ---------------------------
# Main Script Logic
# ---------------------------

log "Starting automation for GitHub repository '$REPO_NAME'."

# Step 1: Create or verify repository
create_repo

# Step 2: Clone the repository
clone_repo

# Step 3: Set up .gitignore
create_gitignore

# Step 4: Commit and push changes
commit_and_push

# Step 5: Create an issue
create_issue

log "Automation completed for '$REPO_NAME'."
