#!/usr/bin/env bash

SOURCE="git@github.com:thomet/shared-git-shell.git"
GIT_USER="git"

# System checks

# Is MacOS or Linux?
if [ "$(uname)" == "Darwin" ]; then
  SYSTEM="macos"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  SYSTEM="linux"
else
  echo "Don't supportet System"
  exit 1
fi
 
# Has git-shell installed?
GIT_SHELL_PATH=`which git-shell`
if [ "$GIT_SHELL_PATH" == "" ]; then
  echo "git-shell is missing. Please install ..."
  exit 1
fi

# Create git user with git-shell access
#if [ "$SYSTEM" == "macos" ]; then
#  LAST_GROUP_ID=`dscl . -list /Groups PrimaryGroupID | awk '{print $2}' | sort -n | tail -1`
#  GROUP_ID=$((LAST_GROUP_ID + 1))
#  sudo dscl . -create /Groups/shared-git-shell
#  sudo dscl . -create /Groups/shared-git-shell PrimaryGroupID $GROUP_ID
#else
#  #TODO: Linux group
#  echo "TODO: LINUX"
#fi

GROUP_ID=504

if [ "$SYSTEM" == "macos" ]; then
  LAST_USER_ID=`dscl . -list /Users UniqueID | awk '{print $2}' | sort -n | tail -1`
  USER_ID=$((LAST_USER_ID + 1))
  sudo dscl . -create /Users/$GIT_USER
  sudo dscl . -create /Users/$GIT_USER UserShell $GIT_SHELL_PATH
  sudo dscl . -create /Users/$GIT_USER RealName 'Shared-Git-Shell User'
  sudo dscl . -create /Users/$GIT_USER UniqueID $USER_ID
  sudo dscl . -create /Users/$GIT_USER PrimaryGroupID $GROUP_ID
  sudo dscl . -create /Users/luser NFSHomeDirectory /Users/$GIT_USER
  sudo createhomedir -c -u $GIT_USER
  
  # Add ssh access
  sudo dscl . append /Groups/com.apple.access_ssh $GIT_USER 
else
  sudo adduser $GIT_USER --shell $GIT_SHELL_PATH --disabled-password
fi

# Clone git repo to git user
sudo git clone $SOURCE ~$GIT_USER/.shared-git-shell

# Symlinc commands
sudo ln -s ~$GIT_USER/.shared-git-shell/git-shell-commands ~$GIT_USER/git-shell-commands

#TODO: Install git share-local command with user/group configuration
