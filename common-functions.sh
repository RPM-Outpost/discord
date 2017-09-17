#!/bin/bash

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

# ask_installpkg
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
			if [[ $1 == "all" || $2 == "all" ]]; then
				rpm_filename=$(find -type f -name '*.rpm' -printf '%P\n')
			else
				rpm_filename=$(find -maxdepth 1 -type f -name '*.rpm' -printf '%P\n' -quit)
			fi
			if [[ $1 == "allowerasing" || $2 == "allowerasing" ]]; then
				sudo dnf install --allowerasing $rpm_filename
			else
				sudo dnf install "$rpm_filename"
			fi
			;;
		*)
			echo "Packag$pl not installed."
	esac
}

# extract archive_file destination [options]
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
