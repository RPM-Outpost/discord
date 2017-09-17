#!/bin/bash

# It's a bad idea to run rpmbuild as root!
if [ "$(id -u)" = "0" ]; then
	disp "$red_bg------------------------ WARNING ------------------------\n\
	      This script should NOT be executed with root privileges!\n\
	      Building rpm packages as root is dangerous and may harm the system!\n\
	      Actually, badly written RPM spec files may execute dangerous command in the system directories.\n\
	      So it is REALLY safer not to run this script as root.\n\
	      If you still want to continue, type \"do it!\" within 5 seconds (type anything else to exit)."
	disp "------------------------ WARNING ------------------------$reset$bold"
	read -t 5 -p '> Do you really want to do it (not recommended)? ' answer
	if [ "$answer" != "do it!" ]; then
		exit
	fi
	style $reset
fi

# Checks that the rpmbuild package is installed.
if ! type 'rpmbuild' > /dev/null; then
	echo 'You need the rpm development tools to create rpm packages.'
	style $bold
	read -n 1 -p '> Install the rpmdevtools package now? [y/N]: ' answer
	echo
	case "$answer" in
		y|Y)
			sudo -p 'Enter your password to install rpmdevtools: ' dnf install rpmdevtools
			;;
		*) 
			echo "${reset}The package won't be installed. Exiting now."
			exit
	esac
	style $reset
else
	disp "${green}rpmbuild detected.$reset"
fi
