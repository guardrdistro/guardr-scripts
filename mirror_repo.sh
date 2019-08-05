#!/bin/bash
#
# This script mirrors git repositories.
#

function usage() {
cat << EOF
usage: ${0#} [-h] -s https://git.drupal.org/projects/something.git -d https://github.com/something/something-mirror.git

This script mirrors git repositories from one services to another. 

Requirements:

 - Git installed on the system and in the PATH.
 - Access to clone the source repo.
 - Access to push changes to the destination repo.

OPTIONS:
 -h			Display this message.
 -s SOURCE_REPO		The source repo.
 -d DEST_REPO		The destination repo.
EOF
}

SOURCE=
DEST=
GIT=$(which git)

while getopts "hs:d:" OPTION
do
  case $OPTION in
    h)
      usage
      exit 0
      ;;
    s)
      SOURCE=$OPTARG
      ;;
    d)
      DEST=$OPTARG
      ;;
    ?)
      usage
      echo "Invalid option $OPTION specified."
      exit 1
      ;;
  esac
done

# Source and destination repos are required.
if [[ -z $SOURCE ]] ||
   [[ -z $DEST ]]
then
  usage
  exit 1
fi

# Setup a temporary directory to work in.
TMPDIR=$(mktemp -d)
if [ ! -e $TMPDIR ]
then
  echo "Failed to create temporary directory."
  exit 1
fi

# Clean up on exit.
trap "exit 1" HUP INT PIPE QUIT TERM
trap 'rm -rf "$TMPDIR"' EXIT

# Clone and mirror the repository.
$GIT clone --mirror $SOURCE $TMPDIR
cd $TMPDIR
$GIT push --mirror $DEST
