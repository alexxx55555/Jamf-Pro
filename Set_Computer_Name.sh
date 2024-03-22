#!/bin/bash

# Get the currently logged-in user
loggedInUser=$(stat -f%Su /dev/console)

# Get the laptop's serial number and extract the last 4 digits
SERIAL_NUMBER=$(system_profiler SPHardwareDataType | grep 'Serial Number' | awk '{print $NF}' | tail -c 5)

# Combine the information into the new name format
NEW_NAME="IL-AQ-${loggedInUser}${SERIAL_NUMBER}"

# Set the system's HostName, LocalHostName, and ComputerName
sudo scutil --set HostName "${NEW_NAME}"
sudo scutil --set LocalHostName "${NEW_NAME}"
sudo scutil --set ComputerName "${NEW_NAME}"

echo "Your computer name has been changed to ${NEW_NAME}"
