#!/bin/bash
#
# Copyright (C) Anders Logg 2009
# Licensed under the GNU GPL Version 3 or any later version
#
# First added:  2009-10-09
# Last changed: 2013-12-19
#
# Modified by Garth Wells 2009
# Modified by Johannes Ring 2013
#
# Parts of this script copied from Dorsal.
#
# This script creates a new release based on the configuration
# file release.conf found in the current directory.

# Parameters
CONF_FILE="release.conf"
PACKAGE=""
BRANCH=""
FILES=""

# Set editor
if [ "x$EDITOR" = "x" ]; then
    EDITOR="emacs -nw"
fi

# Set browser
if [ "x$BROWSER" = "x" ]; then
    BROWSER="firefox"
fi

# Colours for progress and error reporting
BAD="\033[1;37;41m"
GOOD="\033[1;37;42m"
BOLD="\033[1m"

# Function for printing messages
cecho()
{
    COL=$1; shift
    echo -e "${COL}$@\033[0m"
}

# Empty package-specific pre-release function
pre-release()
{
    echo "No package-specific pre-release tasks"
}

# Empty package-specific post-archive function
post-archive()
{
    echo "No package-specific post-archive tasks"
}

# Empty package-specific post-release function
post-release()
{
    echo "No package-specific post-release tasks"
}

# Read configuration
if [ -f $CONF_FILE ]; then
    source $CONF_FILE
else
    cecho $BAD "Unable to read configuration file $CONF_FILE."
    exit 1
fi

# Check variables
if [ "x$PACKAGE" = "x" ]; then
    cecho $BAD "Missing parameter PACKAGE in $CONF_FILE."
    exit 1
fi
if [ "x$BRANCH" = "x" ]; then
    cecho $BAD "Missing parameter BRANCH in $CONF_FILE."
    exit 1
fi
if [ "x$FILES" = "x" ]; then
    cecho $BAD "Missing parameter FILES in $CONF_FILE."
    exit 1
fi

# Make sure we are in the correct branch
cecho $BOLD "Checking out branch $BRANCH..."
git checkout $BRANCH

# Check that repository is synchronized
cecho $BOLD "Checking repository..."
git remote update
GIT_LOG=`git log $BRANCH...origin/$BRANCH --oneline | wc -l`
if [ "$GIT_LOG" -ne "0" ]; then
    cecho $BAD "Repository not synchronized."
    exit 1
fi
# FIXME: Do we need to do more checking?
cecho $GOOD "Repository is in good shape. :-)"

# Check build status
cecho $BOLD "Checking bamboo build status..."
# FIXME: Figure out how to check bamboo status automatically
cecho $GOOD "Bamboo is green. :-)"

# Edit version number in files
cecho $BOLD "Editing version numbers in files..."
sleep 1
for f in $FILES; do
    echo "Updating version number in $EDITOR"
    $EDITOR $f
done
echo "All files edited"

# Do package-specific pre-release tasks
cecho $BOLD "Running package-specific pre-release tasks..."
pre-release
cecho $GOOD "Done!"

# Get version number
cecho $BOLD "Extracting version number..."
if [ -f ChangeLog ]; then
    VERSION=`head -1 ChangeLog | cut -d' ' -f1`
elif [ -f ChangeLog.rst ]; then
    VERSION=`head -1 ChangeLog.rst | cut -d' ' -f1`
else
    cecho $BAD "Missing ChangeLog file, unable to extract version number."
    exit 1
fi
echo "Version number is $VERSION"

# Add new release notes file to repository
if [ -f doc/sphinx/source/releases/v$VERSION.rst ]; then
    cecho $BOLD "Adding doc/sphinx/source/releases/v$VERSION.rst to repository..."
    git add doc/sphinx/source/releases/v$VERSION.rst
    echo "v$VERSION.rst added to repository"
fi

# Commit and push changes
cecho $BOLD "Commiting changes locally..."
git commit -a
echo "Changes commited locally"

# Tag repository
cecho $BOLD "Tagging repository with version number..."
git tag -a $PACKAGE-$VERSION -m '$PACKAGE version $VERSION'
echo "Repository tagged with version $VERSION"

# Commit and push changes
cecho $BOLD "Pushing changes to Bitbucket..."
git push origin $BRANCH

# Also push the new tag
git push origin $PACKAGE-$VERSION
echo "Changes pushed to Bitbucket"

# Create archive
cecho $BOLD "Creating release tarball..."
ARCHIVE="release/$PACKAGE-$VERSION.tar.gz"
mkdir -p release
git archive --prefix=$PACKAGE-$VERSION/ -o $ARCHIVE $PACKAGE-$VERSION
echo "Release tarball created in $ARCHIVE"

# Do package-specific post-archive tasks
cecho $BOLD "Running package-specific post-archive tasks..."
post-archive
cecho $GOOD "Done!"

# Sign archive
cecho $BOLD "Signing release tarball..."
gpg --armor --sign --detach-sig $ARCHIVE
echo "Release tarball signed"

# Upload archive and ChangeLog to fenicsproject.org/pub/software/package
cecho $BOLD "Uploading release tarball and ChangeLog..."
scp $ARCHIVE ChangeLog* fenics-web@fenicsproject.org:pub/software/$PACKAGE/
echo "Release tarball and ChangeLog uploaded"

# Edit version number in files (add '.dev0')
cecho $BOLD "Editing version numbers in files for dev version (add .dev0)..."
sleep 1
for f in $FILES; do
    echo "Updating dev version number in $EDITOR"
    $EDITOR $f
done
echo "All files edited"

# Do package-specific post-release tasks
cecho $BOLD "Running package-specific post-release tasks..."
post-release
cecho $GOOD "Done!"

# Commit and push changes
cecho $BOLD "Commiting changes locally..."
git commit -a
echo "Changes commited locally"

# Commit and push changes
cecho $BOLD "Pushing changes to Bitbucket..."
git push origin $BRANCH

# Update Bitbucket
#cecho $BOLD "Update on Bitbucket"
#echo "Remember to upload tarball"
#$BROWSER https://bitbucket.org/fenics-project/$PACKAGE/downloads

echo
echo "Remember to:"
echo "------------"
echo
echo "1. Bitbucket: Upload the tarball and signature"
echo "2. Bitbucket: Reset the \'next\' branch"
echo "3. Bitbucket: Delete all merged branches"
echo "4. Twitter:   Announce new release using #fenicsnews"
echo "5. Webpage:   Update download links (Johannes)"
echo "6. Webpage:   Update documentation (Johannes)"
echo
echo "And congratulations on the new release, well done!!! :-)"
