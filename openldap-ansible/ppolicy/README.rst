Add Password Policy in OpenLDAP
====================================

This is the guide to enforce Password Policy for OpenLDAP.

The default password policy setting is in ppolicy.ldif.

Setup
------

Load the ppolicy module.::

    $ ldapmodify -H ldap://openldap \
      -D "cn=admin,cn=config" -W -f ppolicy_module.ldif
    Enter LDAP Password:

The Password is LDAP_CONFIG_PASSWORD in /etc/ldap/env/env.yaml.

Open ppolicy_ou.ldif and modify for your env.::

    dn: ou=Policies,dc=iorchard,dc=net
    ou: Policies
    objectClass: organizationalUnit

The attribute dn should be changed.
   
Add Policies organizationalUnit object.::

    $ ldapadd -x -H ldap://openldap \
       -D "cn=admin,dc=iorchard,dc=net" -W -f ppolicy_ou.ldif
    Enter LDAP Password:

The Password is LDAP_ADMIN_PASSWORD in /etc/ldap/env/env.yaml.

Open ppolicy_overlay.ldif and modify for your env.::

   dn: olcOverlay=ppolicy,olcDatabase={1}mdb,cn=config
   objectClass: olcOverlayConfig
   objectClass: olcPPolicyConfig
   olcOverlay: ppolicy
   olcPPolicyDefault: cn=passwordDefault,ou=Policies,dc=iorchard,dc=net
   olcPPolicyHashCleartext: TRUE
   olcPPolicyUseLockout: FALSE
   olcPPolicyForwardUpdates: FALSE

The attribute olcPPolicyDefault should be changed.

Add a new ppolicy overlay object.::

    $ ldapadd -x -H ldap://openldap \
       -D "cn=admin,cn=config" -W -f ppolicy_overlay.ldif
    Enter LDAP Password:

The Password is LDAP_CONFIG_PASSWORD in /etc/ldap/env/env.yaml.

Open ppolicy.ldif and modify for your env.::

    dn: cn=passwordDefault,ou=Policies,dc=iorchard,dc=net
    objectClass: pwdPolicy
    objectClass: person
    objectClass: top
    cn: passwordDefault
    sn: passwordDefault
    pwdAttribute: userPassword
    pwdCheckQuality: 1
    pwdMinAge: 0
    pwdMaxAge: 31536000
    pwdMinLength: 4
    pwdInHistory: 0
    pwdMaxFailure: 10
    pwdFailureCountInterval: 60
    pwdLockout: TRUE
    pwdLockoutDuration: 60
    pwdAllowUserChange: TRUE
    pwdExpireWarning: 0
    pwdGraceAuthNLimit: 0
    pwdMustChange: FALSE
    pwdSafeModify: FALSE

The attribute dn should be changed.

Create a password policy object.::

    $ ldapadd -x -H ldap://openldap \
       -D "cn=admin,dc=iorchard,dc=net" -W -f ppolicy.ldif
    Enter LDAP Password:

The Password is LDAP_ADMIN_PASSWORD in /etc/ldap/env/env.yaml.

That's it!


Verify
-------

Let's change user's password with 3 characters.
It should fail since we set pwdMinLength to 4.::

   $ ldappasswd -H ldap://openldap \
         -D 'uid=jijisa,ou=people,dc=iorchard,dc=net' -WAS
   Old password: <current_password>
   Re-enter old password: <current_password>
   New password: <new_password>
   Re-enter new password: <new_password>
   Enter LDAP Password: <current_password>
   Result: Constraint violation (19)
   Additional info: Password fails quality checking policy

Let's enter the wrong password 10 times. Then your account will be locked out.
since pwdMaxFailure is set to 10.

Enter the right password within 1 minute but it should fail again 
since pwdLockoutDuration is set to 60 seconds.::

   $ ldapsearch -H ldap://ldap-0 \
      -D 'uid=jijisa,ou=people,dc=iorchard,dc=net' -wa \
      -b 'uid=jijisa,ou=people,dc=iorchard,dc=net'
   ldap_bind: Invalid credentials (49)
   (after 10 failures)
   $ ldapsearch -H ldap://ldap-0 \
      -D 'uid=jijisa,ou=people,dc=iorchard,dc=net' -W \
      -b 'uid=jijisa,ou=people,dc=iorchard,dc=net' -LLL
   Enter LDAP Password:
   ldap_bind: Invalid credentials (49)

One minute later, try again with the right password. It will work since
LockoutDuration is passed.::

   $ ldapsearch -H ldap://ldap-0 \
      -D 'uid=jijisa,ou=people,dc=iorchard,dc=net' -W \
      -b 'uid=jijisa,ou=people,dc=iorchard,dc=net' -LLL
   Enter LDAP Password: 
   dn: uid=jijisa,ou=People,dc=iorchard,dc=net
   uid: jijisa
   objectClass: inetOrgPerson
   objectClass: organizationalPerson
   ou: People
   mail: jijisa@iorchard.co.kr
   sn: Kim
   givenName: Heechul
   cn: Heechul Kim

