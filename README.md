![discord logo](discord-logo-wordmark.png)

# Discord rpm
Unofficial RPM package for Discord.

## How to use
1. [Download](https://github.com/RPM-Outpost/discord/archive/master.zip) and extract the zip.
2. Open a terminal and `cd` to the `discord-master` directory.
3. Run one of the following depending on the version you want to create a package for:
    - Discord Stable: `./create-package.sh stable`
    - Discord PTB: &nbsp;&nbsp;&nbsp; `./create-package.sh ptb`
    - Discord Canary: `./create-package.sh canary`
    - Discord Development: `./create-package.sh development`

## Features
- Downloads the latest version of Discord from the official website
- Creates a ready-to-use RPM package
- Discord Stable, PTB, Canary, and Development can be installed at the same time
- Adds Discord to the applications list with a nice HD icon
- Supports Fedora (31) and OpenSUSE (Leap 15.1+).

## More information

### Warning - no accents

The path where you run the script must **not** contain any special character like é, ü, etc. This is a limitation of the rpm tools.

### How to update

When a new version of Discord is released, simply run the script again to get the updated version.

### Dependencies
The `rpmdevtools` package is required to build RPM packages. The script detects if it isn't installed and offers to install it.

### About root privileges
Building an RPM package with root privileges is dangerous, see http://serverfault.com/questions/10027/why-is-it-bad-to-build-rpms-as-root.

## Screenshot
![beautiful screenshot](screenshot.png)
