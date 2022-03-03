---
global:
  storageClass: "$STORAGE_CLASS"

fullnameOverride: "keycloak"

auth:
  adminUser: admin
  adminPassword: "$KEYCLOAK_PASSWORD"
  managementUser: manager
  managementPassword: "$KEYCLOAK_PASSWORD"

nodeSelector:
  openstack-control-plane: enabled

service:
  type: NodePort
  nodePorts:
    http: "30669"
    https: "31196"

postgresql:
  postgresqlUsername: keycloak
  postgresqlPassword: "$KEYCLOAK_DB_PASSWORD"
  postgresqlDatabase: keycloak
...
