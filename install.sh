#!/bin/bash

set_env_vars() {
  local target_disk
  local root_password
  echo "enter the location of the target disk (default: /dev/sda):"
  read target_disk
  export ARCH_INSTALL_DISK="${target_disk:-/dev/sda}"
  echo "enter the desired root password (default: auto-generated):"
  read root_password
  export ROOT_PASSWORD="${root_password}"
}

install_base() {
  cd ./arch-install
  ./pre-install.sh && ./install.sh && ./configure.sh
  cd ../
}

install_dev() {
  local arch_devbox_install_path='/usr/local/src/arch-devbox-install'
  cp -r ./arch-devbox-install "/mnt/$arch_devbox_install_path"
  # get files in
  arch-chroot /mnt "$arch_devbox_install_path/scripts/setup.sh" && arch-chroot /mnt "$arch_devbox_install_path/scripts/install.sh"
  cp ./arch-devbox-install/files/.bash_profile /mnt/home/hobag/
  cp ./arch-devbox-install/files/.xinitrc /mnt/home/hobag
  mkdir -p /mnt/etc/systemd/system/getty@tty1.service.d
  cp ./arch-devbox-install/files/autologin-systemd-service.conf /mnt/etc/systemd/system/getty@tty1.service.d/override.conf
  arch-chroot /mnt "$arch_devbox_install_path/scripts/bootstrap.sh" && arch-chroot /mnt "$arch_devbox_install_path/scripts/tidy_up.sh"
  arch-chroot /mnt rm -rf "$arch_devbox_install_path"
}

install_t420() {
  # install graphics drivers
  pacstrap /mnt xf86-video-intel
  # install audio drivers
  pacstrap /mnt alsa-firmware alsa-tools alsa-utils
}

get_machine_model() {
  pacman -Syq --noconfirm dmidecode > /dev/null
  dmidecode | grep -A3 '^System Information' | \
    grep 'Version' | awk -F':' '{print $2}'
}

install_based_on_machine_model() {
  local machine_model="$1"

  case "$machine_model" in
    *"T420"*)
      install_t420
      ;;
    *)
      echo "Cannot install machine-specific scripts for $machine_model."
      ;;
  esac
}

set_env_vars
git submodule update --init --remote --recursive
install_base && install_dev
machine_model="$(get_machine_model)"

install_based_on_machine_model "$machine_model"
