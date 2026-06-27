#!/bin/bash

main () {
  if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters. Usage: ./provision.sh <machineName:tharja|sidra> <user>"
    return
  fi

  IP=$(cat machines.json | jq -r ".[\"$1\"]")

  echo "Provisioning machine '$1'"
  ssh-copy-id $2@$IP
  ansible-playbook $ANSIBLE_ARGS_EXT -i "$IP," provision-machine.yml --user $2 --diff --ask-become-pass --extra-vars "machine=$1"
}

setup() {
  # Nothing to do yet
  echo "Done."
}

DIR=$(pwd)
setup

cd $DIR
main "$@"