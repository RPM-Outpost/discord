#!/bin/bash
# Author: TheElectronWill
# Script to use terminal colors easily, made for https://github.com/RPM-Outpost

# Colors IDs
id_black=0
id_red=1
id_green=2
id_yellow=3
id_blue=4
id_purple=5
id_cyan=6
id_white=7

disp() { # echo -e
	echo -e $@
}
style() { # echo -e -n
	echo -e -n $@
}
code() { # Escape code
	echo "\033[$1m"
}
fgr() { # Regular foreground color
	let id=30+$1
	if [ $# -eq 2 ]; then
		data="$2;$id"
		echo "$(code $data)"
	else
		echo "$(code $id)"
	fi
}
bgr() { # Regular background color
	let id=40+$1
	echo "$(code $id)"
}
fgh() { # High-intensity foreground color
	let id=90+$1
	echo "$(code $id)"
}
bgh() { # High-intensity background color
	let id=100+$1
	echo "$(code $id)"
}

# Foreground colors        Bold colors                   Underlined colors
black=$(fgr $id_black);    bblack=$(fgr $id_black 1);    ublack=$(fgr $id_black 4);
red=$(fgr $id_red);        bred=$(fgr $id_red 1);        ured=$(fgr $id_red 4);
green=$(fgr $id_green);    bgreen=$(fgr $id_green 1);    ugreen=$(fgr $id_green 4);
yellow=$(fgr $id_yellow);  byellow=$(fgr $id_yellow 1);  uyellow=$(fgr $id_yellow 4);
blue=$(fgr $id_blue);      bblue=$(fgr $id_blue 1);      ublue=$(fgr $id_blue 4);
purple=$(fgr $id_purple);  bpurple=$(fgr $id_purple 1);  upurple=$(fgr $id_purple 4);
cyan=$(fgr $id_cyan);      bcyan=$(fgr $id_cyan 1);      ucyan=$(fgr $id_cyan 4);
white=$(fgr $id_white);    bwhite=$(fgr $id_white 1);    uwhite=$(fgr $id_white 4);

# Background colors
black_bg=$(bgr $id_black)
red_bg=$(bgr $id_red)
green_bg=$(bgr $id_green)
yellow_bg=$(bgr $id_yellow)
blue_bg=$(bgr $id_blue)
purple_bg=$(bgr $id_purple)
cyan_bg=$(bgr $id_cyan)
white_bg=$(bgr $id_white)

# Effects
bold=$(code 1)
underline=$(code 4)
invert=$(code 7)
cross=$(code 9)

# Resets
reset=$(code 0) # resets all
reset_fg=$(code 39) # resets foreground color
reset_bg=$(code 49) # resets background color
reset_font=$(code '22;24') # resets font to regular, ie removes bold and underline

