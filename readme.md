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
boot: gentoo

## 2. testing the network
ping google.com

## 3. creating the partitions 
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

## 4. creating file systems
```bash
mkfs.ext2 /dev/sda1
mkfs.ext4 /dev/sda2
```

## 5. activating the swap partition if exists
```bash
mkswap /dev/sda3
swapon /dev/sda3
```

## 6. mounting the root partition
```bash
mount /dev/sda2 /mnt/gentoo
cd /mnt/gentoo
```

## 7. setting the date and time
```bash
date 
date MMDDhhmmYYYY
```

## 8. downloading the stage tarball
```bash
links www.gentoo.org/main/en/mirrors.xml
select server -> releases/amd64/autobuilds/stage3*.tar.bz2
tar xf stage3*
```

## 9. configuring compile options
```bash
vi /mnt/gentoo/etc/portage/make.conf
```

```bash
CFLAGS="-march=native -O2 -pipe"
# Use the same settings for both variables
CXXFLAGS="${CFLAGS}"
MAKEOPTS="-j4"
VIDEO_CARDS="intel vesa"

INPUT_DEVICES="evdev keyboard mouse synaptics"
NOTUSE="-gtk -gnome -qt4"
USE="${NOTUSE} X systemd acpi alsa ffmpeg flac ftp gif git ipv6 jpeg latex libnotify mp3 mp4 mpeg mtp mysql ogg opengl png python ssl svg systemd wifi xft zsh-completion

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
```

## 10. selecting mirrors
```bash
mirrorselect -i -r -o >> /mnt/gentoo/etc/portage/make.conf
```

## 11. copy DNS info
```bash
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
```

## 12. mounting the necessary filesystems
```bash
mount -t proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
```

## 13. entering the new environment by chrooting into it
This means that the session will change its root (most top-level location that can be accessed) from the current installation environment (installation CD or other installation medium) to the installation system (namely the initialized partitions). Hence the name, change root or chroot.
```bash
chroot /mnt/gentoo /bin/bash
```

## 14. some settings (those in /etc/profile) are reloaded in memory using the source command
```bash
source /etc/profile
```

## 15. change prompt 
The primary prompt is changed to help us remember that this session is inside a chroot environment.
```bash
export PS1="(chroot) ${PS1}"
```

## 16. mounting the boot partition
```bash
mkdir /boot
mount /dev/sda2 /boot
```

## 17. installing an ebuild repository snapshot from the web
```bash
mkdir /usr/portage
emerge-webrsync
```

## 18. updating the Gentoo ebuild repository
```bash
emerge --sync
```

## 19. choosing the right profile
```bash
eselect profile list
eselect profile set <nr>
```

## 20. updating the @world set
It is wise to update the system's @world set so that a base can be established for the new profile.
```bash
emerge --ask --update --deep --newuse @world
```

## 21. configuring the USE variable
USE is one of the most powerful variables Gentoo provides to its users. Several programs can be compiled with or without optional support for certain items.

The easiest way to check the currently active USE settings is to run
```emerge --info | grep ^USE```

A full description on the available USE flags can be found on the system in
less ```/usr/portage/profiles/use.desc```

Users who want to ignore any default USE settings and manage it completely themselves should start the USE definition in ```/etc/portage/make.conf``` with -*:

```bash
USE="-* X acl alsa"
```

## 22. timezone
```bash
echo "Europe/Warsaw" > /etc/timezone
emerge --config sys-libs/timezone-data
```

## 23. configure locales 
```nano /etc/locale.gen```
```bash
locale-gen
eselect locale list
eselect locale set <nr>
```

## 24. reload the environment
```bash
env-update && source /etc/profile && export PS1="(chroot) $PS1"
```


## 25. installing the Linux sources
```bash
emerge --ask sys-kernel/gentoo-sources
```

# manual kernel configuration
```bash
cd /usr/src/linux
make menuconfig
```

```bash
Device Drivers --->
  Generic Driver Options --->
    [*] Maintain a devtmpfs filesystem to mount at /dev

Device Drivers --->
   SCSI device support  --->
      <*> SCSI disk support

File systems --->
  <*> Second extended fs support
  <*> The Extended 3 (ext3) filesystem
  <*> The Extended 4 (ext4) filesystem
  <*> Reiserfs support
  <*> JFS filesystem support
  <*> XFS filesystem support
  <*> Btrfs filesystem support
  DOS/FAT/NT Filesystems  --->
    <*> MSDOS fs support
    <*> VFAT (Windows-95) fs support
 
Pseudo Filesystems --->
    [*] /proc file system support
    [*] Tmpfs virtual memory file system support (former shm fs)

Processor type and features  --->
  [*] Symmetric multi-processing support

Device Drivers --->
  HID support  --->
    -*- HID bus support
    <*>   Generic HID driver
    [*]   Battery level reporting for HID devices
      USB HID support  --->
        <*> USB HID transport layer
  [*] USB support  --->
    <*>     xHCI HCD (USB 3.0) support
    <*>     EHCI HCD (USB 2.0) support
    <*>     OHCI HCD (USB 1.1) support

Processor type and features  --->
   [ ] Machine Check / overheating reporting
   [ ]   Intel MCE Features
   [ ]   AMD MCE Features
   Processor family (AMD-Opteron/Athlon64)  --->
      ( ) Opteron/Athlon64/Hammer/K8
      ( ) Intel P4 / older Netburst based Xeon
      ( ) Core 2/newer Xeon
      ( ) Intel Atom
      ( ) Generic-x86-64
Executable file formats / Emulations  --->
   [*] IA32 Emulation

-*- Enable the block layer --->
   Partition Types --->
      [*] Advanced partition selection
      [*] EFI GUID Partition support

# if UEFI used:
Processor type and features  --->
    [*] EFI runtime service support
    [*]   EFI stub support
    [*]     EFI mixed-mode support

Firmware Drivers  --->
    EFI (Extensible Firmware Interface) Support  --->
        <*> EFI Variable Support via sysfs

[*] Networking support  --->
    -*-   Wireless  ---> 
        <*>   cfg80211 - wireless configuration API
        [*]   cfg80211 wireless extensions compatibility
```

## 26. compiling and installing
```bash
make && make modules_install
```

## 27. copy the kernel image to ```/boot```
```bash
make install
```

## 28. building an initramfs
```bash
emerge --ask sys-kernel/genkernel
genkernel --install initramfs
genkernel --lvm --mdadm --install initramfs
ls /boot/initramfs*
```

## 29. installing firmware
Some drivers require additional firmware to be installed on the system before they work. This is often the case for network interfaces, especially wireless network interfaces.
```bash
emerge --ask sys-kernel/linux-firmware
```

## 30. edit ```/etc/fstab```
```bash]
nano -w /etc/fstab
```

```bash
/dev/sda1   /boot   ext2    defaults,noatime    0 2
/dev/sda2   /       ext4    noatime             0 1
/dev/sda3   none    swap    sw                  0 0
```
set /dev/sda3 only if you've created a swap partition

## 31. set host
```bash
nano -w /etc/conf.d/hostname
```

## 32. configuring the network (TODO)
```bash
emerge --ask net-misc/dhcpcd
emerge --ask net-wireless/iw net-wireless/wpa_supplicant
emerge networkmanager
rc-update add NetworkManager default
```
## 33. add a user and set passwords
```bash
useradd -G users,wheel,audio,portage,cron -s /bin/bash <username>
passwd
passwd <username>
```

## 34. edit sudoers file
```bash
emerge sudo
visudo
```

## 35. install grub
```bash
emerge --ask --verbose sys-boot/grub:2
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
```

## 36. reboot the system
exit
cd
umount -l /mnt/gentoo/dev{/shm,/pts,}
umount -l -R /mnt/gentoo{/boot,/proc,}
reboot

## 37. cleaning
```bash
rm /stage3*
```