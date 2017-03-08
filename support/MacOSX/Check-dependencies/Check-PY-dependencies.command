#!/bin/bash

# Ask user if the app was dragged to /Applications
osascript -e "tell app \"System Events\" to display dialog \"Did you drag the McCode.app bundle to /Applications? \n\n (Otherwise parts of this script could fail...) \""
rc1=$?; 
if [[ $rc1 == 0 ]]; 
then
    echo "OK, proceeding!"
else
    echo "OK, exiting for you to drag the app"
    exit 1
fi

# Check if Xcode commandline tools is installed

# xcode-select -p to check, otherwise
xcode-select -p
rc=$?; 
if [[ $rc != 0 ]]; 
then 
    osascript -e "tell app \"System Events\" to display dialog \"Xcode commandline tools not installed, spawning installation. \n\n!! Please rerun this tool after installation completes !!\""
    rc1=$?; 
    if [[ $rc1 == 0 ]]; 
    then
	echo
	echo
	echo "******************************************************"
	echo "* Requesting installation of Xcode commandline tools *"
	echo "*                                                    *"
	echo "* Please rerun dependency script after Xcode install *"
	echo "******************************************************"
	echo
	sleep 3
	xcode-select --install
	exit 0
    else
	echo
	echo
	echo "!! Not requesting Xcode cmdline install !!"
	echo
	echo
	sleep 3
        exit 1
    fi
else
    echo Xcode commandline tools is already installed!
fi

echo
echo Locating newest McCode package in /Applications/...
echo
NEWESTAPP=`ls -art /Applications | grep Mc | grep \.app | tail -1`
echo Seems /Applications/$NEWESTAPP is where I should go...
echo

osascript -e "tell app \"System Events\" to display dialog \"Allow embedded openmpi binaries in $NEWESTAPP to send/receive through your macOS firewall? \n\n (Please give your passwd to the sudo command in the terminal...) \""
rc1=$?; 
if [[ $rc1 == 0 ]]; 
then
    echo sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /Applications/$NEWESTAPP/Contents/Resources/miniconda3/bin/orted
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /Applications/$NEWESTAPP/Contents/Resources/miniconda3/bin/orted
    echo sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /Applications/$NEWESTAPP/Contents/Resources/miniconda3/bin/orterun
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /Applications/$NEWESTAPP/Contents/Resources/miniconda3/bin/orterun
else
    echo "Not allowing access for openmpi binaries..."
fi

osascript -e "tell app \"System Events\" to display dialog \"We recommend that your user $USER takes ownership of /usr/local - do you want to do this? \n\n (Please give your passwd to the sudo command in the terminal...) \""
rc1=$?; 
if [[ $rc1 == 0 ]]; 
then
    echo sudo chown -R $USER:staff /usr/local
    sudo chown -R $USER:staff /usr/local
    mkdir -p /usr/local/bin
else
    echo "Not taking ownership of /usr/local..."
fi


# Check if the user has a matlab installation - and offer to create a link to the binary in /usr/local
MATLAB=`ls -art /Applications/ |grep MATLAB|wc -l`
if [[ $MATLAB != 0 ]]; 
then
    MATLAB=`ls -art /Applications/ |grep MATLAB|tail -1`
    if [[ -x "/Applications/$MATLAB/bin/matlab" ]];
    then
	osascript -e "tell app \"System Events\" to display dialog \"I found that you have MATLAB installed in /Applications/$MATLAB. \n Do you want that version to be accessible to the tools? \n(I will create a link in /usr/local/bin/matlab, replacing any existing link)\""
	rc1=$?; 
	if [[ $rc1 == 0 ]]; 
	then
	    echo sudo ln -sf /Applications/$MATLAB/bin/matlab /usr/local/bin/matlab
	    sudo ln -sf /Applications/$MATLAB/bin/matlab /usr/local/bin/matlab
	else
	    echo Not installing link to $MATLAB in /usr/local/bin
	fi
	
    fi
fi

