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
}

install_dev() {
  cd ./arch-devbox-install
  # get files in
  ./scripts/setup.sh && ./scripts/install.sh
  cp ./files/.bash_profile /home/hobag/
  mkdir -p /etc/systemd/system/getty/@tty1.service.d
  cp ./files/autologin-systemd-service.conf /etc/systemd/system/getty@tty1.service.d/override.conf
  ./scripts/bootstrap.sh && ./scripts/tidy_up.sh
}

set_env_vars
git submodule update --init
install_base && install_dev
