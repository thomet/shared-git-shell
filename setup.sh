#!/usr/bin/env bash

SOURCE="git@github.com:thomet/shared-git-shell.git"
GIT_USER="git"
SHARED_GIT_GROUP="shared-git-shell"

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

# Create shared-git-shell group
if [ "$SYSTEM" == "macos" ]; then
  if [ "`dscl . -list /Groups PrimaryGroupID | grep $SHARED_GIT_GROUP`" ]; then
    GROUP_ID=`dscl . -list /Groups PrimaryGroupID | grep shared-git-shell | awk '{print $2}'`
    echo "Group $SHARED_GIT_GROUP already exists."
  else
    LAST_GROUP_ID=`dscl . -list /Groups PrimaryGroupID | awk '{print $2}' | sort -n | tail -1`
    GROUP_ID=$((LAST_GROUP_ID + 1))
    sudo dscl . -create /Groups/$SHARED_GIT_GROUP
    sudo dscl . -create /Groups/$SHARED_GIT_GROUP PrimaryGroupID $GROUP_ID
  fi
else
  sudo addgroup $SHARED_GIT_GROUP
fi

# Create git user with git-shell access
if [ "$SYSTEM" == "macos" ]; then
  if [ "`dscl . -list /Users UniqueID | grep $GIT_USER`" ]; then
    echo "User $GIT_USER already exists."
    USER_ID=`dscl . -list /Users UniqueID | grep $GIT_USER | awk '{print $2}'`
  else
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
  fi
else
  sudo adduser $GIT_USER --shell $GIT_SHELL_PATH --disabled-password
  sudo usermod -aG $SHARED_GIT_GROUP $GIT_USER
fi

# Clone git repo to git user
if [ `sudo ls /Users/git | grep .shared-git-shell` ]; then
  echo "shared-git-shell already exists."
else
  sudo git clone $SOURCE ~$GIT_USER/.shared-git-shell
fi

# Symlinc git shell commands
if [ `sudo ls /Users/git | grep git-shell-commands` ]; then
  echo "git-shell-commands already exists."
else
  sudo ln -s ~$GIT_USER/.shared-git-shell/git-shell-commands ~$GIT_USER/git-shell-commands
fi
