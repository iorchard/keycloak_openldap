---
fullnameOverride: "openldap"
replicaCount: $LDAP_REPLICAS
env:
  LDAP_ORGANISATION: "SK Broadband, Inc."
  LDAP_DOMAIN: "skbroadband.com"

adminPassword: "$LDAP_PASSWORD"
configPassword: "$LDAP_PASSWORD"

persistence:
  storageClass: "$STORAGE_CLASS"

image:
  repository: jijisa/openldap
  tag: 1.0.0
  pullPolicy: Always

resources:
  requests:
    cpu: "100m"
    memory: "256Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"

nodeSelector:
  openstack-control-plane: enabled

ltb-passwd:
  enabled: false

phpldapadmin:
  enabled: false

customLdifFiles:
  initial-ous.ldif: |-
    dn: ou=People,dc=skbroadband,dc=com
    objectClass: organizationalUnit
    ou: People

    dn: ou=Group,dc=skbroadband,dc=com
    objectClass: organizationalUnit
    ou: Group
...
