# RPM Package for Discord
I love Discord. But sadly, the devs don't provide any RPM package... Therefore I've made one!  
To be precise, I've made a script that downloads the latest [discord's canary linux build](https://github.com/crmarsh/discord-linux-bugs) and creates a RPM package with it.

## How to use
Run the [create-package.sh](https://github.com/RPM-Outpost/discord/blob/master/create-package.sh) script from the command line.
It will download the latest version of discord and build an RPM package.
Then, install the package with `sudo dnf install <rpm file>`.

### Requirements
You need to install the `rpmdevtools` package to build RPM packages and use the script.
Don't worry: the script detects if it isn't installed, and can install it for you.

### About root privileges
Building an RPM package with root privileges is dangerous, because a mistake in SPEC file could result in running nasty commands.
See http://serverfault.com/questions/10027/why-is-it-bad-to-build-rpms-as-root.

## Update discord
When a new version of discord is released, you can run the `create-package.sh` script again to create an updated package.
Then, simply install the updated package with `sudo dnf install <rpm file>`.

## Supported distributions
- Fedora 25
- Fedora 26

It probably work on other RPM-based distros but I haven't tested it. Let me know if it works for you!
