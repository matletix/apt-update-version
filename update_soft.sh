#!/bin/bash
#
# Install a specific version of a package from custom APT sources.
# Search for matching versions and allow for a more precise version selection.
# Activate the custom sources only for the duration of the script.
#
# Usage :
#
# 1) Modify the following variables to reference the custom sources
# PACKAGE_NAME : name of the apt package to install
# SOFTWARE_SOURCE_FILE : path to the custom apt source file to create
# SOFTWARE_SOURCES : list of sources to put inside the custom apt source file
#
# 2) Call the script with a package version in argument : ./update_soft.sh <PACKAGE_VERSION>

set -e

############### VARIABLES TO EDIT #################
PACKAGE_NAME="gitlab-ee"
SOFTWARE_SOURCE_FILE=/etc/apt/sources.list.d/gitlab_gitlab-ee.list
SOFTWARE_SOURCES=(
  "deb https://packages.gitlab.com/gitlab/gitlab-ee/debian/ buster main"
  "deb-src https://packages.gitlab.com/gitlab/gitlab-ee/debian/ buster main"
)
###################################################

# Set a trap to remove the source file created by this script if it exits for any reason
trap 'rm -f $SOFTWARE_SOURCE_FILE' EXIT

# Check that the version to install is given as a command line argument
if [ -z "$1" ]; then
  echo "No argument supplied. You should supply the version of the package you want to install as a command line argument."
  echo -e "For example, to install the version 14.0.2 of the package:\n$0 14.0.2"
  exit 1
fi

# Activate the software repositories
echo "Activation of the $PACKAGE_NAME sources and update of the repositories..."
printf "%s\n" "${SOFTWARE_SOURCES[@]}" > $SOFTWARE_SOURCE_FILE
apt-get update

# Function to install the selected package version with the approval of the user
install_package() {
  read -rep "Install $PACKAGE_NAME version $CHOSEN_VERSION ? [y/N] " -n 1
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing $PACKAGE_NAME $CHOSEN_VERSION"
    apt-get install -y "$PACKAGE_NAME"="$CHOSEN_VERSION"
  else
    echo "Aborting."
  fi
}

# Search the software packages for a matching version
PACKAGE_VERSIONS=($(apt-cache show $PACKAGE_NAME | grep Version | grep "$1" | cut -d' ' -f2))
if [ ${#PACKAGE_VERSIONS[@]} -eq 0 ]; then
  echo "No $PACKAGE_NAME package found with a matching version of $1. Aborting."
  exit 1
elif [ ${#PACKAGE_VERSIONS[@]} -eq 1 ]; then
  CHOSEN_VERSION=${PACKAGE_VERSIONS[0]}
  echo "Found a matching version for $PACKAGE_NAME : $CHOSEN_VERSION"
  install_package
else
  echo "Found the following matching package versions for $PACKAGE_NAME :"
  for i in "${!PACKAGE_VERSIONS[@]}"; do
    echo "$i => ${PACKAGE_VERSIONS[$i]}"
  done

  while true; do
    read -rep $'\n'"Enter the index of the package you want to install (0..$((${#PACKAGE_VERSIONS[@]} - 1))), or \"A\" to abort : "
    if [[ "$REPLY" == [aA] ]]; then
      echo "Aborting."
      exit 0
    elif [[ "$REPLY" =~ ^[0-9]+$ ]] && [[ "$REPLY" -lt "${#PACKAGE_VERSIONS[@]}" ]]; then
      CHOSEN_VERSION=${PACKAGE_VERSIONS[$REPLY]}
      install_package
      exit 0
    else
      echo "Invalid selection !"
    fi
  done
fi
