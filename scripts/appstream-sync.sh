#!/bin/bash

# Check if the first argument ($1) is NOT provided
if [ ! $1 ]; then
    # Print usage instructions, showing the script name and expected argument
    echo "Usage: $0 <releasenumber>"

    # Provide an example usage with a sample release number
    echo "Ex: $0 39"

    # Exit the script with a status code of 1 (indicates incorrect usage)
    exit 1
else
    # If an argument is provided, assign it to the RELEASE variable
    RELEASE="$1"
fi

# MUST FOLLOW STEPS IN HOW-TO-SIGN-PACKAGES BEFORE THIS WILL WORK

# Loop through all RPM files under the specified release directory and resign them
for i in $(find $HOME/nobara/appstream/$RELEASE/ -type f -name '*.rpm'); do
  rpm --resign $i
done

# Recreate the repository metadata for the RPM files (verbose mode enabled)
sudo createrepo -v $HOME/nobara/appstream/$RELEASE/x86_64/

# Set full read/write/execute permissions recursively for the appstream directory
chmod -R 777 $HOME/nobara/appstream

# Upload the signed packages using rclone to three remote destinations


# Requires buckets to be configured with rclone at $HOME/.config/rclone/rclone.conf
# Upload to "nobara" remote storage
rclone copy $HOME/nobara/appstream/$RELEASE nobara:nobara-appstream/$RELEASE --timeout=36000m >/dev/null 2>&1 &

# Upload to "nobara-linode" remote (likely Linode-hosted)
rclone copy $HOME/nobara/appstream/$RELEASE nobara-linode:nobara-appstream-linode.nobaraproject.org/$RELEASE --timeout=36000m >/dev/null 2>&1 &

# Upload to "nobara-do" remote (likely DigitalOcean-hosted)
rclone copy $HOME/nobara/appstream/$RELEASE nobara-do:nobara-appstream-m1/$RELEASE --timeout=36000m >/dev/null 2>&1 &
