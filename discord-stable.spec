# Defined by the caller (ie the script):
# version_number
# downloaded_dir
# desktop_file

%define install_dir /opt/discord
%define apps_dir /usr/share/applications

Name:		discord
Version:	%{version_number}
Release:	stable%{?dist}
Summary:	Free Voice and Text Chat for Gamers.

Group:		Applications/Internet
License:	Proprietary
URL:		https://discordapp.com/
BuildArch:	x86_64
Requires:   glibc, alsa-lib, GConf2, libnotify, nspr >= 4.13, nss >= 3.27, libstdc++ >= 6, libX11 >= 1.6, libXtst >= 1.2, libappindicator, libcxx%{?_isa}

%description
All-in-one voice and text chat for gamers that’s free, secure, and works on both your desktop and phone. 
It’s time to ditch Skype and TeamSpeak.

%prep

%build

%install
mkdir -p "%{buildroot}%{install_dir}"
mkdir -p "%{buildroot}%{apps_dir}"
mv "%{downloaded_dir}"/* "%{buildroot}%{install_dir}"
cp "%{desktop_file}" "%{buildroot}%{apps_dir}"
chmod +x "%{buildroot}%{install_dir}"/*.so

%files
/*


