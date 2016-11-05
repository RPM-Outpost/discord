# RPM Package for Discord
I love Discord. But sadly, the devs don't provide any RPM package... Therefore I've made one!  
It is based on the [discord's canary linux build](https://github.com/crmarsh/discord-linux-bugs).  

## How to use
### Build the rpm package yourself
Run the [create-package.sh](https://github.com/RPM-Outpost/discord/blob/master/create-package.sh) script (from the command line).
It will download the latest version of discord and build an RPM package.
Then, install the package with `sudo dnf install <rpm file>`.

**Note:** You need to install the `rpmdevtools` package to use the script.
Don't worry: the script detects if it isn't installed, and can install it for you.

### Use the rpm package I've already built
I've already built a package with my script.
You can download this package [here](https://github.com/RPM-Outpost/discord/blob/master/RPMs/x86_64/discord-0.0.10-canary.fc24.x86_64.rpm).

### How to update
When a new version of discord is released, you can run the `create-package.sh` script again to create an updated package.
Or you can download an updated package from my github repository.
Then, simply install the updated package with `sudo dnf install <rpm file>`.
