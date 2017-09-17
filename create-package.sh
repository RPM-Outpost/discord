#!/bin/bash
# Author: TheElectronWill
# This script downloads the latest version of Discord for linux, and creates a package with rpmbuild.

source terminal-colors.sh # Adds color variables
source basic-checks.sh # Checks that rpmbuild is available and that the script isn't started as root
source common-functions.sh # Adds utilities functions

rpm_dir="$PWD/RPMs"
work_dir="$PWD/work"
downloaded_dir="$work_dir/discord"
desktop_model="$PWD/discord.desktop"
arch='x86_64'

# Checks that the version (stable/canary) is given as a parameter.
if [[ $# -ne 1 || $1 != "stable" && $1 != "canary" ]]; then
	disp "${red}Wrong or missing parameters!$reset"
	echo 'Usage: create-package.sh stable/canary'
	exit
fi
discord_type="$1"
spec_file="$PWD/discord-$discord_type.spec"

if [[ $discord_type == "canary" ]]; then
	app_name='Discord Canary'
	exe_name='DiscordCanary'
	download_url='https://discordapp.com/api/download/canary'
	cut_part=3
	desktop_file="$work_dir/discord-canary.desktop"
else
	app_name='Discord'
	exe_name='Discord'
	download_url='https://discordapp.com/api/download'
	cut_part=2
	desktop_file="$work_dir/discord-stable.desktop"
fi	

# Downloads the discord tar.gz archive and puts its name in the global variable archive_name.
download_discord() {
	echo "Downloading discord $discord_type for linux..."
	wget -q --show-progress --content-disposition "${download_url}?platform=linux&format=tar.gz"
	archive_name="$(ls *.tar.gz)"
}

manage_dir "$work_dir" 'work'
manage_dir "$rpm_dir" 'RPMs'
cd "$work_dir"

# Downloads discord if needed.
archive_name="$(ls *.tar.gz 2>/dev/null)"
if [ $? -eq 0 ]; then
	echo "Found the archive \"$archive_name\"."
	ask_yesno 'Use this archive instead of downloading a new one?'
	case "$answer" in
		y|Y)
			echo 'Existing archive selected.'
			;;
		*)
			rm "$archive_name"
			download_discord
	esac
else
	download_discord
fi

# Extracts the archive:
echo
if [ ! -d "$downloaded_dir" ]; then
	mkdir "$downloaded_dir"
fi
extract "$archive_name" "$downloaded_dir" "--strip 1" # --strip 1 gets rid of the top archive's directory


# Gets the discord's version number + icon file name
echo 'Analysing the files...'
version_number="$(echo "$archive_name" | cut -d'-' -f$cut_part | rev | cut -c 8- | rev)"
# cut -d'-' -fn  splits the archive's name around the '-' character, and takes the n-th part
# For example if archive_name is "discord-0.0.1.tar.gz" we get "0.0.1.tar.gz"
# Then, rev | cut -c 8- | rev  reverse the string, removes the first 7 characters, and re-reverse it.
# This actually removes the last 8 characters, ie the ".tar.gz" part.
# So in our example we'll get version_number=0.0.1

cd "$downloaded_dir"
icon_name="$(ls *.png)"
echo " -> Version: $version_number"
echo " -> Icon: $icon_name"


echo 'Creating the .desktop file...'
sed "s/@version/$version_number/; s/@icon/$icon_name/; s/@exe/$exe_name/; s/@name/$app_name/; s/@type/$discord_type/"\
	"$desktop_model" > "$desktop_file"


disp "${yellow}Creating the RPM package (this may take a while)..."
rpmbuild --quiet -bb "$spec_file" --define "_topdir $work_dir" --define "_rpmdir $rpm_dir"\
	--define "version_number $version_number" --define "downloaded_dir $downloaded_dir"\
	--define "desktop_file $desktop_file"

disp "${bgreen}Done!${reset_font}"
disp "The RPM package is located in the \"RPMs/$arch\" folder."
disp '----------------'

ask_remove_dir "$work_dir"
ask_installpkg
