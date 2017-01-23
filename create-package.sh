#!/bin/sh
# Author: TheElectronWill
# This script downloads the latest version of Discord for linux, and creates a package with rpmbuild.

# Defines the needed paths
desktop_model="$PWD/discord.desktop"
spec_file="$PWD/discord.spec"

rpm_dir="$PWD/RPMs"
work_dir="$PWD/work"
downloaded_dir="$work_dir/discord"
desktop_file="$work_dir/discord.desktop"

# It's a bad idea to run rpmbuild as root!
if [ "$(id -u)" = "0" ]; then
	echo '------------------------ WARNING ------------------------'
	echo 'This script should NOT be executed with root privileges!'
	echo 'Building rpm packages as root is dangerous and may harm the system!'
	echo 'Actually, badly written RPM spec files may execute dangerous command in the system directories.'
	echo 'So it is REALLY safer not to run this script as root.'
	echo 'If you still want to run this script as root, type "do it!" within 5 seconds (type anything else to exit):'
	read -t 5 -p 'Do you really want to do it (not recommended)? ' answer
	if [ "$answer" != "do it!" ]; then
		exit
	fi
	echo '------------------------ WARNING ------------------------'
fi

# Checks that rpmbuild is installed.
if ! type 'rpmbuild' > /dev/null; then
	echo 'You need the rpm development tools to create rpm packages.'
	read -n 1 -p 'Do you want to install the rpmdevtools package now? [y/N]' answer
	echo
	case "$answer" in
		y|Y)
			sudo -p 'Enter your password to install rpmdevtools: ' dnf install rpmdevtools
			;;
		*) 
			echo "Ok, I won't install rpmdevtools."
			exit
	esac
else
	echo "rpmbuild detected!"
fi

# Downloads the discord tar.gz archive and puts its name in the global variable archive_name.
download_discord() {
	echo 'Downloading discord canary for linux...'
	wget -q --show-progress --content-disposition 'https://discordapp.com/api/download/canary?platform=linux&format=tar.gz'
	archive_name="$(ls *.tar.gz)"
}

# Asks the user if they want to remove the specified directory, and removes it if they want to.
ask_remove_dir() {
	read -n 1 -p "Do you want to remove the \"$1\" directory? [y/N]" answer
	echo
	case "$answer" in
		y|Y)
			rm -r "$1"
			echo "\"$1\" directory removed."		
			;;
		*)
			echo "Ok, I won't remove it."
	esac
	echo
}

# If the specified directory exists, asks the user if they want to remove it.
# If it doesn't exist, creates it.
manage_dir() {
	if [ -d "$1" ]; then
		echo "The $2 directory already exist. It may contain outdated things."
		ask_remove_dir "$1"
	fi
	mkdir -p "$1"
}

manage_dir "$work_dir" 'work'
manage_dir "$rpm_dir" 'RPMs'
cd "$work_dir"

# Downloads discord if needed.
archive_name="$(ls *.tar.gz 2>/dev/null)"
if [ $? -eq 0 ]; then
	echo "Found $archive_name"
	read -n 1 -p 'Do you want to use this archive instead of downloading a new one? [y/N]' answer
	echo
	case "$answer" in
		y|Y)
			echo 'Ok, I will use this archive.'
			;;
		*)
			rm "$archive_name"
			download_discord
	esac
else
	download_discord
fi

echo
echo 'Extracting the files...'
archive_name="$(ls *.tar.gz)"
if [ ! -d "$downloaded_dir" ]; then
	mkdir "$downloaded_dir"
fi
tar -xzf "$archive_name" -C "$downloaded_dir" --strip 1
# --strip 1 gets rid of the top archive's directory


# Gets the discord's version number + icon file name
echo 'Analysing the files...'
version_number="$(echo "$archive_name" | cut -d'-' -f3 | rev | cut -c 8- | rev)"
# Explaination on how it works:
# cut -d'-' -f3  splits the archive's name around the '-' character, and takes the 3rd part
# For example if archive_name is "discord-canary-0.0.10.tar.gz" we get "0.0.10.tar.gz"
# Then, rev | cut -c 8- | rev  reverse the string, removes the first 7 characters, and re-reverse it.
# This actually removes the last 8 characters, ie the ".tar.gz" part.
# So in our example we'll get version_number=0.0.10

cd "$downloaded_dir"
icon_name="$(ls *.png)"
echo "    Archive: $archive_name"
echo "    Version: $version_number"
echo "    Icon: $icon_name"


echo 'Creating .desktop file...'
sed "s/_version/$version_number/; s/_icon/$icon_name/" "$desktop_model" > "$desktop_file"


echo 'Creating the RPM package (this may take a while)...'
rpmbuild --quiet -bb "$spec_file" --define "_topdir $work_dir" --define "_rpmdir $rpm_dir"\
	--define "version_number $version_number" --define "downloaded_dir $downloaded_dir"\
	--define "desktop_file $desktop_file"

echo
echo '------------------------- Done! -------------------------'
echo "The RPM package is located in the \"RPMs/x86_64\" folder."
ask_remove_dir "$work_dir"
