openldap-ansible
================

This is a guide to install OpenLDAP using docker.

Supported OS
----------------

* Debian 11 (bullseye)

Assumptions
-------------

* The first node is the ansible deployer.
* Ansible user in every node has a sudo privilege.
  we will use vault_sudo_pass in ansible vault for sudo password.
* Ansible user in every node has the same password.
  We will use vault_ssh_pass in ansible vault.
* All nodes should be in /etc/hosts on every node.::

    $ cat /etc/hosts
    127.0.0.1	localhost
    192.168.21.32 ldap-0   # The first openldap server
    192.168.21.33 ldap-1   # The second openldap server
    192.168.21.34 openldap # KeepAlived VIP

Install packages.::

   $ sudo apt update
   $ sudo apt -y install python3-venv sshpass

Install ansible in virtual env
----------------------------------

Create virtual env.::

   $ python3 -m venv ~/.envs/ldap

Activate the virtual env.::

   $ source ~/.envs/ldap/bin/activate

Install ansible.::

   $ python -m pip install -U pip
   $ python -m pip install wheel
   $ python -m pip install ansible

Prepare
---------

Go to openldap-ansible directory.::

   $ cd openldap-ansible

Copy default inventory and create hosts file for your environment.::

   $ export MYSITE="mysite" # put your site name
   $ cp -a inventory/default inventory/$MYSITE
   $ vi inventory/$MYSITE/hosts
    ldap-0 ansible_host=192.168.21.32 ansible_port=22 ansible_user=clex ansible_connection=local
    ldap-1 ansible_host=192.168.21.33 ansible_port=22 ansible_user=clex

Modify hostname, ip, port, and username.

Create and update ansible.cfg.::

   $ sed "s/MYSITE/$MYSITE/" ansible.cfg.sample > ansible.cfg

Create a vault file for several passwords.::

   $ ./vault.sh
   user password: 
   LDAP admin password: 
   Encryption successful

Edit group_vars/all/vars.yml for your environment before "Warn" comment.::

   $ vi inventory/$MYSITE/group_vars/all/vars.yml
   ---
   ldap_env:
     org: "iOrchard"
     domain: "iorchard.net"
     basedn: "dc=iorchard,dc=net"
     adminpw: "{{ ldap_password }}"
     cfssl_org: "iOrchard"
     cfssl_ou: "Cloud Expert Group"
     cfssl_loc: "Wonju-Si"
     cfssl_state: "Gangwon-Do"
     cfssl_country: "Korea"

   keepalived_interface: "eth0"
   keepalived_vip: "192.168.21.34"
   
   # replication setting - if there are two nodes, set it to "true".
   ldap_replication: "false"
 
   ######################################################
   # Warn: Do not edit below if you are not an expert.  #
   ######################################################

Check the connectivity to all nodes.::

   $ ansible -m ping all

Run
----

Run a playbook.::

   $ ansible-playbook site.yml


Check
------

Run ldapsearch.::

   $ ldapsearch -x -H ldap://ldap-0  -b '' -s base namingContexts
   # extended LDIF
   #
   # LDAPv3
   # base <> with scope baseObject
   # filter: (objectclass=*)
   # requesting: namingContexts 
   #
   
   #
   dn:
   namingContexts: dc=iorchard,dc=net
   
   # search result
   search: 2
   result: 0 Success
   
   # numResponses: 2
   # numEntries: 1

The output should show namingContexts.

Do ldapsearch.::

    $ ldapsearch -x -H ldap://openldap -b 'dc=iorchard,dc=net' -D 'cn=admin,dc=iorchard,dc=net' -W
    Enter LDAP Password:
   # extended LDIF
   #
   # LDAPv3
   # base <dc=iorchard,dc=net> with scope subtree
   # filter: (objectclass=*)
   # requesting: ALL
   #
   
   # iorchard.net
   dn: dc=iorchard,dc=net
   objectClass: top
   objectClass: dcObject
   objectClass: organization
   o: iOrchard
   dc: iorchard
   
   # People, iorchard.net
   dn: ou=People,dc=iorchard,dc=net
   ou: People
   objectClass: organizationalUnit
   
   # Group, iorchard.net
   dn: ou=Group,dc=iorchard,dc=net
   ou: Group
   objectClass: organizationalUnit
   
   # search result
   search: 2
   result: 0 Success
   
   # numResponses: 4
   # numEntries: 3

The output should give 3 entries (numentries: 3).

