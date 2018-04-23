#!/usr/bin/env bash

ROOT_UID=0

# check if executed as a user
if [[ "$UID" == "$ROOT_UID" ]]; then
  echo "Please run this script as a user"
  exit 126
fi

create_directories()
{
  echo "==> Creating directories"
  mkdir -p $HOME/tmp
  mkdir -p $HOME/mnt
  mkdir -p $HOME/documents
  mkdir -p $HOME/music
  mkdir -p $HOME/movies
  mkdir -p $HOME/downloads
  mkdir -p $HOME/repo
  mkdir -p $HOME/pictures/screenshots
}

install_packages()
{

  sudo emerge-webrsync

  sudo emerge --update --deep \
  x11-base/xorg-server x11-apps/xinit x11-wm/i3 x11-misc/rofi \
  x11-misc/i3status x11-misc/i3lock media-gfx/scrot lxde-base/lxrandr \
  x11-misc/redshift app-editors/vim net-misc/youtube-dl net-p2p/rtorrent \
  app-text/zathura app-misc/mc x11-terms/xterm www-client/links \
  sys-libs/ncurses media-sound/mpd media-sound/ncmpcpp media-sound/mpc \
  media-gfx/feh media-plugins/alsa-plugins x11-apps/xbacklight \
  dev-util/cmake net-misc/curl dev-util/ ctags dev-lang/lua media-sound/gmtp \
  x11-apps/setxkbmap app-misc/neofetch app-arch/p7zip app-arch/unrar \
  app-arch/unzip dev-lang/python sys-devel/gcc dev-vcs/git virtual/ssh \
  media-fonts/terminus-font app-shells/zsh sys-power/acpi sys-process/htop \
  games-roguelike/nethack www-client/firefox

  # When the installation is finished, some environment variables will need to re-initialized before continuing. Source the profile with this command.
  sudo env-update
  sudo source /etc/profile
}

config_other()
{
  chsh -s /bin/zsh $USER
  xrdb -merge $HOME/.Xresources

  sudo mkdir -p /var/games/nethack

  # disable a capslock
  setxkbmap -option caps:escape &
}

main()
{
  create_directories
  install_packages
  config_other
}

main
