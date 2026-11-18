#!/bin/sh
# Prints the Ansible Vault password from the macOS Keychain (service "atmos-ansible-vault").
# The password itself is never stored in this repository.
exec security find-generic-password -a "$USER" -s atmos-ansible-vault -w
