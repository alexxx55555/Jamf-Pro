#!/bin/bash

# Enable FileVault script

# Check if FileVault is already on
FV_STATUS=$(fdesetup status)

if [[ "$FV_STATUS" == *"FileVault is On"* ]]; then
    echo "FileVault is already enabled."
    exit 0
else
    echo "Enabling FileVault..."

    # Assuming the current logged-in user
    CURRENT_USER=$(stat -f%Su /dev/console)

    # Enable FileVault
    sudo fdesetup enable -user "$CURRENT_USER" -defer /var/tmp/fvsetup.plist

    if [ $? -eq 0 ]; then
        echo "FileVault activation initiated. A reboot is required to complete the process."
        # Consider moving the recovery key to a secure location
    else
        echo "Error: FileVault activation failed."
        exit 1
    fi
fi
