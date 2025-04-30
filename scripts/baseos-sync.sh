#!/bin/bash

# Check if the first argument ($1) is NOT provided
if [ ! $1 ]; then
    # Inform the user how to use the script, including an example
    echo "Usage: $0 <releasenumber>"
    echo "Ex: $0 39"
    exit 1;
else
    # Assign the provided release number to the RELEASE variable
    RELEASE="$1"
fi

# Create the destination directory if it doesn't exist
mkdir -p $HOME/nobara/copr

# Enable required repositories for syncing BaseOS content
sudo dnf config-manager --set-enabled nobara-baseos-$RELEASE
sudo dnf config-manager --set-enabled nobara-baseos-multilib-$RELEASE

# Download packages and metadata from the enabled repos into local directory
reposync --repoid=nobara-baseos-$RELEASE -m --download-metadata -p $HOME/nobara/copr --downloadcomps
reposync --repoid=nobara-baseos-multilib-$RELEASE -m --download-metadata -p $HOME/nobara/copr --downloadcomps

# Disable the repos again after syncing
sudo dnf config-manager --set-disabled nobara-baseos-$RELEASE
sudo dnf config-manager --set-disabled nobara-baseos-multilib-$RELEASE

# Recreate repository metadata locally for both synced repos
createrepo -v $HOME/nobara/copr/nobara-baseos-$RELEASE
createrepo -v $HOME/nobara/copr/nobara-baseos-multilib-$RELEASE

# Requires buckets to be configured with rclone at $HOME/.config/rclone/rclone.conf

# Upload to "nobara" remote
rclone copy $HOME/nobara/copr/nobara-baseos-$RELEASE nobara:nobara-baseos/$RELEASE >/dev/null 2>&1 &
rclone copy $HOME/nobara/copr/nobara-baseos-multilib-$RELEASE/ nobara:nobara-baseos-multilib/$RELEASE >/dev/null 2>&1 &

# Upload to "nobara-linode" remote
rclone copy $HOME/nobara/copr/nobara-baseos-$RELEASE nobara-linode:nobara-baseos-linode.nobaraproject.org/$RELEASE >/dev/null 2>&1 &
rclone copy $HOME/nobara/copr/nobara-baseos-multilib-$RELEASE/ nobara-linode:nobara-baseos-multilib-linode.nobaraproject.org/$RELEASE >/dev/null 2>&1 &

# Upload to "nobara-do" remote
rclone copy $HOME/nobara/copr/nobara-baseos-$RELEASE nobara-do:nobara-baseos-m1/$RELEASE >/dev/null 2>&1 &
rclone copy $HOME/nobara/copr/nobara-baseos-multilib-$RELEASE/ nobara-do:nobara-baseos-multilib-m1/$RELEASE >/dev/null 2>&1 &
