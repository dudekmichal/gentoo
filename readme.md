# notes
These installation notes and kernel config are configured for me and my
computer (Lenovo G580). It can work for you but it does not have to.
Feel free to follow my instructions, but keep in mind that you will probably have to
add some drivers while kernel configuration and use different USE flags in
```/etc/portage/make.conf```.

# how it looks like
![N|Solid](https://raw.github.com/qeni/gentoo/master/img/screenshot.png)

# emerge cheatsheet

```bash
# install a package:
emerge <name>

# install a package and update all packages it depends on:
emerge -u <name> 

# update a package, all packages it depends on and all packages they depend on (--update --deep):
emerge -uD <name>

# uninstall a package:
emerge -C package

# search for packages - names only (--search):
emerge -s <keyword>

# search for packages (their description):
emerge -S <keyword>

# view what would have been installed (--pretend):
emerge -p <name>

# only download archive + dependencies (--fetchonly):
emerge -f <name>

# complete system update:
emerge -uD @world

# view what USE flags are used to configure and install a package:
emerge -pv <name>

# sync the Gentoo ebuild repository using the mirrors by obtaining a snapshot that is (at most) a day old:
emerge-webrsync
```

# installation

## 0. view the Gentoo handbook during the installation
```bash
links https://wiki.gentoo.org/wiki/Handbook:AMD64
```

## 1. select a kernel
```bash
boot: gentoo
```

## 2. test the network
```bash
ping google.com
```

If there's no connection:

### 2.1 list interfaces
```bash
ip link
```

### 2.2 set the interface up
```bash
ip link set <interface> up
```

## 3. create the partitions 
```bash
# -t dos option forces to read the partition table using the MBR format.
fdisk -t dos /dev/sda
    # create partitions:
    # /dev/sda1 -> /boot (Type 'a' to toggle the bootable flag)
    # /dev/sda2 -> /
    # /dev/sda3 -> /swap (optional)
    n - new partition
    ...
    a - makes bootable
    p - print all partitions
    l - list of partition codes
    t - change type of partitions
        82 - swap
        83 - Linux
    d - delete partitions
    w - write changes
```

## 4. create file systems
```bash
mkfs.ext2 /dev/sda1
mkfs.ext4 /dev/sda2
```

## 5. activate the swap partition if exists
```bash
mkswap /dev/sda3
swapon /dev/sda3
```

## 6. mount the root partition
```bash
mount /dev/sda2 /mnt/gentoo
cd /mnt/gentoo
```

## 7. set date and time
```bash
date 
date MMDDhhmmYYYY
```

## 8. download the stage tarball
```bash
links www.gentoo.org/main/en/mirrors.xml
select server -> releases/amd64/autobuilds/stage3*.tar.bz2
tar xf stage3*
```

## 9. configure compile options
```bash
vi /mnt/gentoo/etc/portage/make.conf
```

```bash
CFLAGS="-march=native -O2 -pipe"
# Use the same settings for both variables
CXXFLAGS="${CFLAGS}"
MAKEOPTS="-j4"
VIDEO_CARDS="intel vesa"

INPUT_DEVICES="evdev keyboard mouse synaptics libinput"
NOTUSE="-qt4"
USE="${NOTUSE} X acpi alsa ffmpeg flac ftp fuse gif git ipv6 jpeg latex libnotify mp3 mp4 mpeg mtp mysql ncurses ogg opengl png python python3 ssl svg wifi xft zsh-completion"

# which software licenses are allowed
ACCEPT_LICENSE="*"
#ACCEPT_LICENSE="-* @FREE"

PORTAGE_TMPDIR=/var/tmp

# the location of the temporary files for Portage
PORTAGE_TMPDIR="/var/tmp"

# the location where Portage will store the downloaded source code archives
DISTDIR=/var/gentoo/distfiles

AUTOCLEAN="yes"

LINGUAS="pl en_US"

# BIOS/MBR is pc, 64-bit UEFI is efi-64, 32-bit UEFI is efi-32
GRUB_PLATFORMS="pc"
```

## 10. select mirrors
In order to download source code quickly it is recommended to select a fast/close mirror.
```bash
mirrorselect -i -r -o >> /mnt/gentoo/etc/portage/make.conf
```

A second important step in selecting mirrors is to configure the Gentoo ebuild
repository via the ```/etc/portage/repos.conf/gentoo.conf```. This file
contains the sync information needed to update the package repository.
```bash
mkdir -p /mnt/gentoo/etc/portage/repos.conf
```

Next, copy the Gentoo repository configuration file provided by Portage
```bash
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf
```

## 11. copy DNS info
One thing still remains to be done before entering the new environment and that is copying over the DNS information in ```/etc/resolv.conf```. This needs to be done to ensure that networking still works even after entering the new environment. ```/etc/resolv.conf``` contains the name servers for the network.
```bash
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
```

## 12. mount the necessary filesystems
In a few moments, the Linux root will be changed towards the new location. To make sure that the new environment works properly, certain filesystems need to be made available there as well.
```bash
mount -t proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
```

## 13. enter the new environment by chrooting into it
This means that the session will change its root (most top-level location that can be accessed) from the current installation environment (installation CD or other installation medium) to the installation system (namely the initialized partitions). Hence the name, change root or chroot.

The root location is changed from ```/``` (on the installation medium) to ```/mnt/gentoo/``` (on the partitions) using chroot
```bash
chroot /mnt/gentoo /bin/bash
```

## 14. reload /etc/profile
Some settings (those in /etc/profile) are reloaded in memory using the source command
```bash
source /etc/profile
```

## 15. change prompt 
The primary prompt is changed to help us remember that this session is inside a chroot environment.
```bash
export PS1="(chroot) ${PS1}"
```

## 16. mount the boot partition
```bash
mkdir /boot
mount /dev/sda2 /boot
```

## 17. instal an ebuild repository snapshot from the web
```bash
mkdir /usr/portage
emerge-webrsync
```

## 18. update the Gentoo ebuild repository
```bash
emerge --sync
```

## 19. install vim
```bash
emerge app-editors/vim dev-vcs/git
```

## 20. choose the right profile
A profile is a building block for any Gentoo system. Not only does it specify default values for USE, CFLAGS, and other important variables, it also locks the system to a certain range of package versions. These settings are all maintained by Gentoo's Portage developers.
```bash
eselect profile list
eselect profile set <nr>
```

## 21. update the @world set
It is wise to update the system's @world set so that a base can be established for the new profile.
```bash
emerge --ask --update --deep --newuse @world
```

## 22. configure the USE variable
USE is one of the most powerful variables Gentoo provides to its users. Several programs can be compiled with or without optional support for certain items.

The easiest way to check the currently active USE settings is to run
```emerge --info | grep ^USE```

A full description on the available USE flags can be found on the system in ```/usr/portage/profiles/use.desc```.

Users who want to ignore any default USE settings and manage it completely themselves should start the USE definition in ```/etc/portage/make.conf``` with -*:

```bash
USE="-* X acl alsa"
```

## 23. timezone
```bash
echo "Europe/Warsaw" > /etc/timezone
emerge --config sys-libs/timezone-data
```

## 24. configure locales 
```vim /etc/locale.gen```
```bash
locale-gen
eselect locale list
eselect locale set <nr>
```

## 25. reload the environment
```bash
env-update && source /etc/profile && export PS1="(chroot) $PS1"
```


## 26. install the Linux sources
```bash
emerge --ask sys-kernel/gentoo-sources
```

## 27. manual kernel configuration
```bash
git clone https://github.com/qeni/gentoo.git
cp gentoo/kernel-config /usr/src/linux/
cd /usr/src/linux
make menuconfig
> load kernel-config file
```

## 28. compile a kernel
```bash
make && make modules_install
```

## 29. copy the kernel image to ```/boot```
```bash
make install
```

## 30. install firmware
Some drivers require additional firmware to be installed on the system before they work. This is often the case for network interfaces, especially wireless network interfaces.
```bash
emerge --ask sys-kernel/linux-firmware
```

## 31. edit ```/etc/fstab```
```bash
vim /etc/fstab
```

```bash
/dev/sda1   /boot   ext2    defaults,noatime    0 2
/dev/sda2   /       ext4    noatime             0 1
/dev/sda3   none    swap    sw                  0 0
```
set /dev/sda3 only if you've created a swap partition

## 32. set host
```bash
vim /etc/conf.d/hostname
```

## 33. configure the network
```bash
emerge --ask net-misc/dhcpcd net-wireless/iw net-wireless/wpa_supplicant net-misc/wicd sys-firmware/b43-firmware sys-apps/iproute2 net-wireless/wireless-tools
rc-update add wicd default
rc-update add dhcpcd default
```
## 34. add a user and set passwords for him and root
```bash
useradd -G users,wheel,audio,portage,cron -s /bin/bash <username>
passwd
passwd <username>
```

## 35. edit sudoers file
```bash
emerge sudo
visudo
```

## 36. install grub
```bash
emerge -av sys-boot/grub:2
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
vim /boot/grub/grub.cfg
```

## 37. reboot the system and login as a created user
```bash
exit
cd
umount -l /mnt/gentoo/dev{/shm,/pts,}
umount -l -R /mnt/gentoo{/boot,/proc,}
reboot
```

## 38. create directories in $HOME
```bash
mkdir -p $HOME/{tmp, mnt, documents, music, movies, downloads, repo, pictures/screenshots}
```

## 39. sync the Gentoo ebuild repository
```bash
sudo emerge-webrsync
```

## 40. install additional packages
```bash
sudo emerge --update --deep \
x11-base/xorg-server x11-apps/xinit x11-wm/i3-gaps x11-misc/rofi \
x11-misc/i3status x11-misc/i3lock media-gfx/scrot lxde-base/lxrandr \
x11-misc/redshift app-editors/vim app-vim/jedi net-misc/youtube-dl net-p2p/rtorrent \
app-text/zathura app-misc/mc x11-terms/xterm www-client/links \
sys-libs/ncurses media-sound/mpd media-sound/ncmpcpp media-sound/mpc media-video/vlc \
media-gfx/feh media-plugins/alsa-plugins media-sound/alsamixer-app media-libs/alsa-lib x11-apps/xbacklight \
dev-util/cmake net-misc/curl net-misc/dhcpcd sys-apps/dbus dev-lang/lua media-sound/gmtp \
app-misc/neofetch app-arch/p7zip app-arch/unrar app-portage/genlop app-editors/leafpad \
app-arch/unzip dev-lang/python sys-devel/gcc dev-vcs/git net-misc/openssh \
media-fonts/terminus-font app-shells/zsh sys-power/acpi sys-process/htop \
x11-apps/xbacklight sys-fs/ntfs3g games-roguelike/nethack www-client/firefox
```

## 41. re-initialize env variables
When the installation is finished, some environment variables will need to re-initialized before continuing.
```bash
sudo env-update
sudo source /etc/profile
```

## 42. clone dotfiles
```bash
git clone https://github.com/qeni/dotfiles /home/qeni/repo/dotfiles
rsync -rvlkEth /home/qeni/dotfiles/.* ~/
```

## 43. add daemons
```bash
rc-update add sshd default
```

## 44. change default shell to zsh
```bash
chsh -s /bin/zsh $USER
```

## 45. configure nethack
```bash
sudo mkdir -p /var/games/nethack
sudo mv ~/.nethack_record /var/games/nethack/record
```

## 46. go and conquer the world
```bash
startx
```
