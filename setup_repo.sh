#!/usr/bin/env bash

# ---------------------------
#     Configuration
# ---------------------------
DEFAULT_BRANCH="default"

log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# ---------------------------
#     Functions
# ---------------------------

# Prompt user for input with a default value
prompt() {
  local message="$1"
  local default="$2"
  read -p "$message [$default]: " input
  echo "${input:-$default}"
}

# Check if `gh` and `git` are installed
check_dependencies() {
  if ! command -v git &>/dev/null; then
    log "[-] Git is not installed. Please install Git before running this script."
    exit 1
  fi

  if ! command -v gh &>/dev/null; then
    log "[-] GitHub CLI (gh) is not installed. Please install gh before running this script."
    exit 1
  fi

  log "[+] All dependencies are installed."
}

# Initialize a new local Git repository
initialize_git_repo() {
  local repo_dir
  repo_dir=$(prompt "Enter the directory to initialize the repository in" "$PWD")
  mkdir -p "$repo_dir" && cd "$repo_dir" || exit
  log "[+] Repository will be created in $repo_dir."

  if [ -d ".git" ]; then
    log "[+] A Git repository already exists in this directory."
  else
    git init
    log "[+] Initialized a new Git repository in $repo_dir."
  fi
}

# Create README.md file
create_readme() {
  local repo_name
  repo_name=$(prompt "Enter the name of the repository" "my-repo")
  echo "# $repo_name" >README.md
  log "[+] Created README.md for repository $repo_name."
}

# Add files and commit
add_and_commit() {
  git add .
  local commit_message
  commit_message=$(prompt "Enter the commit message" "Initial commit")
  git commit -m "$commit_message"
  log "[+] Added files and committed with message: $commit_message."
}

# Set up the remote GitHub repository
setup_remote_repo() {
  local repo_name visibility
  repo_name=$(prompt "Enter the name of the GitHub repository" "my-repo")
  visibility=$(prompt "Enter the visibility (public/private)" "public")

  if gh repo view "$repo_name" &>/dev/null; then
    log "[+] Repository '$repo_name' already exists on GitHub."
    git remote add origin "https://github.com/$(gh auth status -t | grep 'Logged in' | awk '{print $5}')/$repo_name.git"
  else
    gh repo create "$repo_name" --$visibility --source . --remote origin --push
    log "[+] Created GitHub repository '$repo_name' and linked it to local Git."
  fi
}

# Push to remote
push_to_remote() {
  git branch -M "$DEFAULT_BRANCH"
  git push -u origin "$DEFAULT_BRANCH" || {
    log "[-] Failed to push changes to remote. Ensure your branch name and permissions are correct."
    exit 1
  }
  log "[+] Pushed changes to remote repository on branch $DEFAULT_BRANCH."
}

# ---------------------------
#     Main Script Logic
# ---------------------------
log "Starting automated repository setup..."

# Check for dependencies
check_dependencies

# Initialize Git repository
initialize_git_repo

# Create README.md
create_readme

# Add and commit files
add_and_commit

# Set up GitHub remote repository
setup_remote_repo

# Push changes to remote
push_to_remote

log "Repository setup completed successfully!"
