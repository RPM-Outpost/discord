#!/bin/sh
# Author: TheElectronWill
# This script downloads the latest version of Discord for linux, and creates a package with rpmbuild.

rpm_dir=$PWD/RPMs

desktop_model=$PWD/discord.desktop
spec_file=$PWD/discord.spec

work_dir=$PWD/work
downloaded_dir=$work_dir/discord
desktop_file=$work_dir/discord.desktop

# Checks that rpmbuild is installed
if ! type 'rpmbuild' > /dev/null
then
	echo "You need the rpm development tools to create rpm packages"
	read -p "Do you want to install rpmdevtools now? This will run sudo dnf install rpmdevtools. [y/N]" answer
	case $answer in
		[Yy]* ) sudo dnf install rpmdevtools;;
		* ) 
			echo "Ok, I won't install rpmdevtools."
			exit
		;;
	esac
else
	echo "rpmbuild detected!"
fi

# Download the discord tar.gz archive and puts its name in the global variable archive_name.
function download_discord {
	echo 'Downloading discord canary for linux...'
	wget -q --show-progress --content-disposition "https://discordapp.com/api/download/canary?platform=linux&format=tar.gz"
	archive_name=$(ls *.tar.gz)
}

# Asks the user if he/she wants to remove the specified directory, and removes it if he wants to.
function ask_remove_dir {
	read -p "Do you want to remove the \"$1\" directory? [y/N]" answer
	case $answer in
		[Yy]* )
			rm -r "$1"
			echo "\"$1\" directory removed."		
			;;
		* ) echo "Ok, I won't remove it." ;;
	esac
}

# If the specified directory exists, asks the user if he/she wants to remove it.
# If it doesn't exist, creates it.
function manage_dir {
	if [ -d "$1" ]; then
		echo "The $2 directory already exist. It may contain outdated things."
		ask_remove_dir "$1"
	else
		mkdir "$work_dir"
	fi
}

manage_dir "$work_dir" 'work'
manage_dir "$rpm_dir" 'RPMs'
cd "$work_dir"

# Download discord if needed
archive_name=$(ls *.tar.gz)
if [ $? -eq 0 ]; then
	echo "Found $archive_name"
	read -p 'Do you want to use this archive instead of downloading a new one? [y/N]' answer
	case $answer in
		[Yy]* )
			echo 'Ok, I will use this this archive.'
			;;
		* )
			download_discord
			;;
	esac
else
	download_discord
fi

# Extracts the archive
echo 'Extracting the files...'
archive_name=$(ls *.tar.gz)
if [ ! -d "$downloaded_dir" ]; then
	mkdir "$downloaded_dir"
fi
tar -xzf "$archive_name" -C "$downloaded_dir" --strip 1
# --strip 1 gets rid of the top archive's directory


# Gets the discord's version number + icon file name
echo 'Analysing the files...'
version_number=$(echo "$archive_name" | cut -d'-' -f3 | rev | cut -c 8- | rev)
# Explaination on how it works:
# cut -d'-' -f3  splits the archive's name around the '-' character, and takes the 3rd part
# For example if archive_name is "discord-canary-0.0.10.tar.gz" we get "0.0.10.tar.gz"
# Then, rev | cut -c 8- | rev  reverse the string, removes the first 7 characters, and re-reverse it.
# This actually removes the last 8 characters, ie the ".tar.gz" part.
# So in our example we'll get version_number=0.0.10
cd "$downloaded_dir"
icon_name=$(ls *.png)
echo "Archive: $archive_name"
echo "Version: $version_number"
echo "Icon: $icon_name"

# Creates a .desktop file:
echo 'Creating .desktop file...'
sed "s/_version/$version_number/; s/_icon/$icon_name/" "$desktop_model" > "$desktop_file"

# Chooses the spec file based on the system's architecture and build the packages
echo 'Creating the RPM package...'
rpmbuild -bb $spec_file --define "_topdir $work_dir" --define "_rpmdir $rpm_dir" --define "version_number $version_number" --define "downloaded_dir $downloaded_dir" --define "desktop_file $desktop_file"

echo '-----------'
echo 'Done!'
echo "The RPM package is located in the \"RPMs/x86_64\" folder."

# Removes the work directory if the user wants to
ask_remove_dir "$work_dir"
