#!/usr/bin/env bash

# System checks

# Is MacOS or Linux?
if [ "$(uname)" == "Darwin" ]; then
  SYSTEM="macos"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  SYSTEM="linux"
else
  echo "Don't supportet System"
  exit
fi
 
# Has git-shell installed?
GIT_SHELL_PATH=`which git-shell`
if [ "$GIT_SHELL_PATH" == "" ]; then
  echo "git-shell is missing. Please install ..."
  exit
fi

# Create git user with git-shell access
if [ "$SYSTEM" == "macos" ]; then
  echo "sudo dscl / -create /Users/git UserShell $GIT_SHELL_PATH"
else
  echo "sudo adduser git --shell $GIT_SHELL_PATH --disabled-password"
fi

# Copy the commands to the git user
GIT_USER_HOME=`echo ~git`
echo "cp -r ./git-shell-commands $GIT_USER_HOME/"

#TODO: Install git share-local command
