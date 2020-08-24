#!/bin/sh

echo "/usr/local/etc/svncheckin/svncheckin.sh"

# Basic argument stuff

if [[ -z $1 ]]
then
  echo "ERROR: Target empty"
  echo "Usage: svncheckin TARGETDIRECTORY"
  exit
else
  continue
fi

if [[ -n $2 ]]
then
  echo "ERROR: Too many arguments."
  echo "Usage: svncheckin TARGETDIRECTORY"
  exit
else
  continue
fi

# If the above two pass, define the TARGET as the first argument

TARGET=$1
# Drop trailing slash
TARGET=${1%/}

# Make sure it's a directory

ISDIRECTORY=$(ls -al $TARGET | grep "drwxr-xr-x")
if [[ -z $ISDIRECTORY ]]
then
  echo "ERROR: Target is not a directory. Must be a directory."
  echo "Usage: svncheckin TARGETDIRECTORY"
  exit
else
  continue
fi

# Set the other variables

FULLPATH=$(/bin/readlink -f $TARGET)
TODAY=$(date +%s)
BACKUP=$(echo "$TARGET""_BACKUP_""$TODAY")

# Check if the SVN root repo exists and create it if not
ROOTREPO="/usr/src/svn"
if [[ -d $ROOTREPO ]]
then
  continue
else
  echo "First time? Adding $ROOTREPO"
  mkdir $ROOTREPO
fi

## Create the repo directories and add the post-commit svnnotify hook
REPO="$ROOTREPO/$TARGET"
if [[ -d $REPO ]]
then
  echo "ERROR: $REPO exists. Is it already in SVN?"
  exit
else
  echo "Adding $REPO"
  mkdir $REPO
fi

## Add the repo directories to SVN
svnadmin create --fs-type fsfs /usr/src/svn/$TARGET
svn mkdir file:///usr/src/svn/$TARGET/trunk -m ''
svn mkdir file:///usr/src/svn/$TARGET/branches -m ''
svn mkdir file:///usr/src/svn/$TARGET/tags -m ''

## Go to the parent directory of your working files
cd $FULLPATH
cd ..

## Move your working files to a backup directory
mv $TARGET/ $BACKUP/

## Check-out from the repo a folder with the name of your working directory
svn checkout file:///usr/src/svn/$TARGET/trunk $TARGET

## If there are any existing files inside BACKUP, copy them to the working directory
cp -R $BACKUP/* $TARGET/
cd $TARGET
svn add ./*

# Initial commit, and update the working directory
svn commit -m "Initial check-in via svncheckin.sh"
svn update

# Let the user know about the backup.
echo ""
echo "A backup folder has been created at $BACKUP"
echo "When you feel comfortable all is well, this may be deleted."

