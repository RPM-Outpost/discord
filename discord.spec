# Defined by the caller (ie the script):
# pkg_name
# pkg_version
# pkg_req
# downloaded_dir
# desktop_file

%define install_dir /opt/%{pkg_name}
%define apps_dir /usr/share/applications
%define _build_id_links none
%global _enable_debug_package 0
%global debug_package %{nil}
%global __os_install_post /usr/lib/rpm/brp-compress %{nil}

Name:		%{pkg_name}
Version:	%{pkg_version}
Release:	2%{?dist}
Summary:	Free Voice and Text Chat for Gamers.

Group:		Applications/Internet
License:	Proprietary
URL:		https://discordapp.com/
BuildArch:	x86_64
Requires:   %{pkg_req}

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
chmod +x "%{buildroot}%{install_dir}"/Discord*

%files
%{install_dir}
%{apps_dir}/*

%post
cd "%{install_dir}"
sh postinst.sh
