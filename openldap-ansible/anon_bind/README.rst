Disallow anonymous bind
========================

This is the guide to disallow anonymous bind in openldap.

Setup
------

Execute disallow_anon_bind.ldif using ldapmodify.::

    $ ldapmodify -H ldap://openldap \
      -D "cn=admin,cn=config" -W -f disallow_anon_bind.ldif
    Enter LDAP Password:

The Password is LDAP_CONFIG_PASSWORD in /etc/ldap/env/env.yaml.

That's it!

Verify
-------

Before applying the above configuration, 
I search with anonymous bind and get the result even if there is no results
since database access is not allowed for anonymous bind.::

   $ ldapsearch -x -H ldaps://ldap-0
   # extended LDIF
   #
   # LDAPv3
   # base <dc=iorchard,dc=net> (default) with scope subtree
   # filter: (objectclass=*)
   # requesting: ALL
   #
   
   # search result
   search: 2
   result: 32 No such object
   
   # numResponses: 1

After applying the above configuration,
I search with anonymous bind and get the error message.::

   $ ldapsearch -x -H ldaps://ldap-0
   ldap_bind: Inappropriate authentication (48)
      additional info: anonymous bind disallowed

If I search with admin credential, I get the result.::

   $ ldapsearch -x -H ldaps://ldap-0 -b 'dc=iorchard,dc=net' -D 'cn=admin,dc=iorchard,dc=net' -W
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


