#!/bin/bash
# Author: TheElectronWill
# This script downloads the latest version of Discord for linux, and creates a package with rpmbuild.

source terminal-colors.sh # Adds color variables
source common-functions.sh # Adds utilities functions
source basic-checks.sh # Checks that rpmbuild is available and that the script isn't started as root

rpm_dir="$PWD/RPMs"
work_dir="$PWD/work"
downloaded_dir="$work_dir/discord"
desktop_model="$PWD/discord.desktop"
spec_file="$PWD/discord.spec"
arch='x86_64'

# Settings according to the distribution
if [[ $distrib == "redhat" ]]; then
	pkg_req='glibc, alsa-lib, GConf2, libnotify, nspr >= 4.13, nss >= 3.27, libstdc++ >= 6, libX11 >= 1.6, libXtst >= 1.2, libappindicator, libcxx%{?_isa}'
elif [[ $distrib == "suse" ]]; then
	pkg_req='glibc, alsa, gconf2, libnotify, mozilla-nspr >= 4.13, mozilla-nss >= 3.27, libstdc++6, libX11 >= 1.6, libXtst >= 1.2, libappindicator, libc++1'
else
	disp "${red}Sorry, your distribution isn't supported (yet).$reset"
	exit
fi	

# Checks that the version (stable/canary) is given as a parameter.
if [[ $# -ne 1 || $1 != "stable" && $1 != "canary" ]]; then
	disp "${red}Wrong or missing parameters!$reset"
	echo 'Usage: create-package.sh stable/canary'
	exit
fi

# Settings according to the discord type (canary or stable)
if [[ $1 == "canary" ]]; then
	app_name='Discord Canary'
	exe_name='DiscordCanary'
	pkg_name='discord-canary'
	download_url='https://discordapp.com/api/download/canary'
	cut_part=3
	desktop_file="$work_dir/discord-canary.desktop"
else
	app_name='Discord'
	exe_name='Discord'
	pkg_name='discord-stable'
	download_url='https://discordapp.com/api/download'
	cut_part=2
	desktop_file="$work_dir/discord-stable.desktop"
fi

# Downloads the discord tar.gz archive and puts its name in the global variable archive_name.
download_discord() {
	echo "Downloading $app_name for linux..."
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
pkg_version="$(echo "$archive_name" | cut -d'-' -f$cut_part | rev | cut -c 8- | rev)"
# cut -d'-' -fn  splits the archive's name around the '-' character, and takes the n-th part
# For example if archive_name is "discord-0.0.1.tar.gz" we get "0.0.1.tar.gz"
# Then, rev | cut -c 8- | rev  reverse the string, removes the first 7 characters, and re-reverse it.
# This actually removes the last 8 characters, ie the ".tar.gz" part.
# So in our example we'll get pkg_version=0.0.1

cd "$downloaded_dir"
icon_name="$(ls *.png)"
echo " -> Version: $pkg_version"
echo " -> Icon: $icon_name"


echo 'Generating desktop entry...'
sed "s/@version/$pkg_version/; s/@icon/$icon_name/; s/@exe/$exe_name/; s/@name/$app_name/; s/@dir/$pkg_name/"\
	"$desktop_model" > "$desktop_file"

disp "${yellow}Creating the RPM package (this may take a while)..."
rpmbuild --quiet -bb "$spec_file" --define "_topdir $work_dir" --define "_rpmdir $rpm_dir"\
	--define "pkg_version $pkg_version" --define "downloaded_dir $downloaded_dir"\
	--define "desktop_file $desktop_file" --define "pkg_name $pkg_name" --define "pkg_req $pkg_req"

disp "${bgreen}Done!${reset_font}"
disp "The RPM package is located in the \"RPMs/$arch\" folder."
disp '----------------'

ask_remove_dir "$work_dir"
ask_installpkg
