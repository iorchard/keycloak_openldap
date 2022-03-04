LDAP_PASSWORD = <password>
LDAP_REPLICAS = 2
KEYCLOAK_DB_PASSWORD = $(LDAP_PASSWORD)
KEYCLOAK_PASSWORD = $(LDAP_PASSWORD)
STORAGE_CLASS = rbd

#
# Do not edit below
#
values_files = openldap-values.yml keycloak-values.yml

.PHONY: setup get-helm3 openldap

setup:
	@echo -n "Setup: creating custom values yaml file..."
	@env LDAP_PASSWORD="$(LDAP_PASSWORD)" \
		 LDAP_REPLICAS="$(LDAP_REPLICAS)" \
		 STORAGE_CLASS="$(STORAGE_CLASS)" \
	envsubst < openldap-values.yml.tpl > openldap-values.yml
	@env KEYCLOAK_DB_PASSWORD="$(KEYCLOAK_DB_PASSWORD)" \
		 KEYCLOAK_PASSWORD="$(KEYCLOAK_PASSWORD)"  \
		 STORAGE_CLASS="$(STORAGE_CLASS)" \
	envsubst < keycloak-values.yml.tpl > keycloak-values.yml
	@echo "Done!"

get-helm3:
ifeq (,$(wildcard /usr/local/bin/helm3))
	curl -fsSL -o /tmp/get_helm3.sh \
		https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
	chmod 0700 /tmp/get_helm3.sh
	BINARY_NAME="helm3" /tmp/get_helm3.sh
endif

openldap: setup get-helm3
	helm3 upgrade --install openldap --namespace cloudpc \
		--values openldap-values.yml \
		openldap 

keycloak: setup get-helm3
	helm3 upgrade --install keycloak --namespace cloudpc \
		--values keycloak-values.yml \
		keycloak

install: setup get-helm3 openldap keycloak

clean:
	rm -f $(values_files)
