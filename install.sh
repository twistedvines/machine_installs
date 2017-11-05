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

set_env_vars
git submodule update --init
cd ./arch-install
./pre-install.sh && ./install.sh && ./configure.sh
