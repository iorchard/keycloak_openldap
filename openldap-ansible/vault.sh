#!/bin/bash
if [ -f .vaultpass ]; then
        echo "Error) .vaultpass file exists. Remove it first."
        exit 1
fi
VAULTFILE="inventory/${MYSITE}/group_vars/all/vault.yml"

# Create vault file.
read -s -p "$USER password: " USERPASS; echo ""
read -s -p "LDAP admin password: " LDAPPASS; echo ""
echo "---" > $VAULTFILE
echo "vault_ssh_password: '$USERPASS'" >> $VAULTFILE
echo "vault_sudo_password: '$USERPASS'" >> $VAULTFILE
echo "vault_ldap_password: '$LDAPPASS'" >> $VAULTFILE
echo -n "..." >> $VAULTFILE
head /dev/urandom |tr -dc A-Za-z0-9 |head -c 8 > .vaultpass
chmod 0400 .vaultpass
sudo chattr +i .vaultpass
ansible-vault encrypt $VAULTFILE
