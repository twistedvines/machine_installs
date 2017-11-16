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
}

set_env_vars
git submodule update --init
install_base && install_dev
