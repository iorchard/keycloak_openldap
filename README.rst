Keycloak and OpenLDAP
=========================

Keycloak is an open source identity and access management solution.
(https://www.keycloak.org/)

OpenLDAP is an open source implementation of the Lightweight Directory Access
Protocol. (https://www.openldap.org/)

This is a repo to deploy keycloak and openldap on kubernetes cluster.

Preflight
----------

Copy Makefile.sample to Makefile and edit Makefile 
to override helm chart values.::

   $ cp Makefile.sample Makefile
   $ vi Makefile
    LDAP_PASSWORD = <password>
    LDAP_REPLICAS = 2
    KEYCLOAK_DB_PASSWORD = $(LDAP_PASSWORD)
    KEYCLOAK_PASSWORD = $(LDAP_PASSWORD)
    STORAGE_CLASS = rbd
    
    #
    # Do not edit below
    #
   ...

Set the variables as you like.

* LDAP_PASSWORD: openldap admin password
* LDAP_REPLICAS: the number of openldap pods
* KEYCLOAK_DB_PASSWORD: DB root password use by keycloak
  (postgresql pod will be installed.)
* STOAGE_CLASS: kubernetes storage class name
  (Persistent Volume is created and used by openldap and keycloak)

Install
--------

Create values yaml files.::

   $ make setup

There will be two files (openldap-values.yml, keycloak-values.yml).

Install openldap.::

   $ make openldap

Install keycloak.::

   $ make keycloak

Or you can install all at once.::

   $ make install


Verify 
-------

Make sure openldap is running.::

   $ kubectl get pods -n cloudpc -l app=openldap
    NAME         READY   STATUS    RESTARTS   AGE
    openldap-0   1/1     Running   0          3m49s
    openldap-1   1/1     Running   0          2m14s

Send a query to openldap.::

   $ kubectl exec -it openldap-0 -n cloudpc -- ldapsearch -x -b dc=skbroadband,dc=com -D "cn=admin,dc=skbroadband,dc=com" -W
   Enter LDAP Password:
   ...
   # skbroadband.com
   dn: dc=skbroadband,dc=com
   objectClass: top
   objectClass: dcObject
   objectClass: organization
   o: SK Broadband, Inc.
   dc: skbroadband
	...

Make sure keycloak is running.::

   $ kubectl get pods -n cloudpc -l app=keycloak
   NAME         READY   STATUS    RESTARTS   AGE
   keycloak-0   1/1     Running   0          3m29s

Post setup
-------------

Open a browser and go to keycloak web site (http://<controller_ip>:30669/).
Login as admin.

Create a realm.
++++++++++++++++++

After logging into the Keycloak administrative console with our admin user,
click the "Master" dropdown on the top-left and click "Add realm".
Type name "cloudpc" and click the Create button.

Link openldap to keycloak
++++++++++++++++++++++++++++

Go to User Federation and select ldap from the "Add Provider` dropdown.
Then choose the following options::

    Edit Mode: Writable
    Sync Registrations: On
    Vendor: Other
    Connection URL: ldap://openldap.cloudpc.svc.cluster.local
    Users DN: ou=People,dc=skbroadband,dc=com
    Authentication Type: simple
    Bind DN: cn=admin,dc=skbroadband,dc=com
    Bind Credentials: <openldap admin password>

Once we've entered all of these details, we can use the "Test connection" and
"Test authentication" buttons to make sure that everything works.
Assuming it does, we can select "Save" to complete the addition of a User
Federation provider.

Set up group membership
+++++++++++++++++++++++++++

For this we need to go back to the "User Federation" entry on the left menu,
choose our ldap entry and select the "Mappers" tab.

We then need to click "Create".
Enter ldap-group as the Name for our federation mapper and
select group-ldap-mapper as the "Mapper Type".
Then enter the following::

    LDAP Groups DN: ou=Group,dc=skbroadband,dc=com
    Group Object Classes: groupOfUniqueNames
    Membership LDAP Attribute: uniqueMember
    User Groups Retrieve Strategy: LOAD_GROUPS_BY_MEMBER_ATTRIBUTE

And click save. This configuration is slightly different to the default and
ensures that the memberOf attribute works correctly.

Add common name mapper
+++++++++++++++++++++++++

Go back to LDAP Mappers and click Create.
Then entery the following.::

   Name: common name
   Mapper Type: full-name-ldap-mapper

And click Save.

Modify first name mapper
++++++++++++++++++++++++++++


The first name attribute is givenName but the default attribute in keycloak
set to cn. That is not correct.

So change it in first name mapper.::

   LDAP attribute: givenName

Click Save.

Verify setup
+++++++++++++

Add a user in Users menu in keycloak and confirm openldap has the user.::

   $ kubectl exec -it openldap-0 -n cloudpc -- ldapsearch -x -b dc=skbroadband,dc=com -D "cn=admin,dc=skbroadband,dc=com" -W 'uid=jijisa'
   Enter LDAP Password:
   ...
   # jijisa, People, skbroadband.com
   dn: uid=jijisa,ou=People,dc=skbroadband,dc=com
   uid: jijisa
   objectClass: inetOrgPerson
   objectClass: organizationalPerson
   mail: jijisa@iorchard.co.kr
   givenName: Heechul
   sn: Kim
   cn: Heechul Kim

Yes, The added user in keycloak is registered in openldap.

