Recon and Run Policies After User logs in


#!/bin/bash

#variables
event1=$4
event2=$5
event3=$6
event4=$7
event5=$8
event6=$9


# Get the currently logged in user
loggedInUser=$(defaults read /Library/Preferences/com.apple.loginwindow lastUserName)
echo "Current user is $loggedInUser"

# get UID for current User
currentUID=$(dscl . -list /Users UniqueID | grep $loggedInUser | awk '{print $2;}')
echo "$loggedInUser UID is $currentUID"

# Check and see if we're currently running as the user we want to setup - pause and wait if not
while [ $currentUID -ne 502 ] && [ $currentUID -ne 501 ]; do
    echo "Currently logged in user is NOT the 501 or 502 user. Waiting."
    sleep 2
    loggedInUser=`/usr/bin/stat -f "%Su" /dev/console`
    currentUID=$(dscl . -list /Users UniqueID | grep $loggedInUser | awk '{print $2;}')
    echo "Current user is $loggedInUser with UID $currentUID"
done

# Now that we have the correct user logged in - need to wait for the login to complete so we don't start too early
dockStatus=$(pgrep -x Dock)
echo "Waiting for Desktop"
while [ "$dockStatus" == "" ]; do
  echo "Desktop is not loaded. Waiting."
  sleep 2
  dockStatus=$(pgrep -x Dock)
done

# Start the imaging process since we're now running as the correct user.
echo "501 or 502 user is now logged in, continuing setup."
jamf recon
sleep 1
jamf policy -event $event1
jamf policy -event $event2
jamf policy -event $event3
jamf policy -event $event4
jamf policy -event $event5
jamf policy -event $event6
