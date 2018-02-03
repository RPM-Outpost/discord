#!/bin/bash
# Author: TheElectronWill
# Various functions used by the scripts of https://github.com/RPM-Outpost
# This script requires terminal-colors.sh

# Initializes $installer and $distrib
if hash dnf 2>/dev/null; then
	# Fedora, CentOS with dnf installed
	installer="dnf install --allowerasing"
	distrib="redhat"
elif hash yum 2>/dev/null; then
	# CentOS
	installer="yum install"
	distrib="redhat"
elif hash zypper 2>/dev/null; then
	# OpenSUSE
	installer="zypper install"
	distrib="suse"
elif hash urpmi 2>/dev/null; then
	# Mageia
	installer="urpmi"
	distrib="mageia"
else
	# Unknown
	installer="exit"
	distrib="unknown"
fi

# Initializes $wget_progress: detects if the option --show-progress is available
wget --help | grep -q '\--show-progress' && wget_progress="-q --show-progress" || wget_progress=""

# ask_yesno question
## Asks a yes/no question and stores the result in the 'answer' variable
ask_yesno() {
	style $reset$bold
	read -n 1 -p "> $1 [y/N]: " answer
	echo
	style $reset
}

# ask_remove_dir directory
## Asks the user if they want to remove the specified directory, and removes it if they want to.
ask_remove_dir() {
	ask_yesno "Remove the directory \"$1\"?"
	case "$answer" in
		y|Y)
			rm -r "$1"
			echo "Directory removed."		
			;;
		*)
			echo "Directory not removed."
	esac
	echo
}

# manage_dir directory directory_short_name
## If the specified directory exists, asks the user if they want to remove it.
## If it doesn't exist, creates it.
manage_dir() {
	if [ -d "$1" ]; then
		echo "The $2 directory already exist and may contain outdated data."
		ask_remove_dir "$1"
	fi
	mkdir -p "$1"
}

# ask_installpkg [all]
## Asks the user if they want to install the newly created package.
ask_installpkg() {
	if [[ $1 == "all" || $2 == "all" ]]; then
		pl='es'
	else
		pl='e'
	fi
	ask_yesno "Install the packag$pl now?"
	case "$answer" in
		y|Y)
			cd "$rpm_dir/$arch"
			if [[ $1 == "all" ]]; then
				rpm_filename=$(find -type f -name '*.rpm' -printf '%P\n')
			else
				rpm_filename=$(find -maxdepth 1 -type f -name '*.rpm' -printf '%P\n' -quit)
			fi
			sudo_install $rpm_filename
			;;
		*)
			echo "Packag$pl not installed."
	esac
}

# sudo_install pkg [options]
sudo_install() {
	sudo $installer "$@"
}

# sudo_install_prompt prompt pkg [options]
sudo_install_prompt() {
	if [[ $# -eq 2 ]]; then
		sudo -p "$1" $installer "$2"
	else
		sudo -p "$1" $installer "$2" $3
	fi
}

# extract archive_file destination [option1 [option2]]
extract() {
	echo "Extracting \"$1\"..."
	if [[ "$1" == *.tar.gz ]]; then
		command="tar -xzf \"$1\" -C \"$2\""
	elif [[ "$1" == *.tar.xz ]];then
		command="tar -xJf \"$1\" -C \"$2\""
	elif [[ "$1" == *.tar.bz2 ]];then
		command="tar -xjf \"$1\" -C \"$2\""
	elif [[ "$1" == *.tar ]];then
		command="tar -xf \"$1\" -C \"$2\""
	elif [[ "$1" == *.zip ]]; then
		command="unzip -q \"$1\" -d \"$2\""
	else
		disp "${red}Unsupported archive type for $1"
		return 10
	fi
	if [ $# -eq 3 ]; then
		eval $command $3 # Custom options
	elif [ $# -eq 4 ]; then
		eval $command $3 $4 # Custom options
	else
		eval $command
	fi
}
