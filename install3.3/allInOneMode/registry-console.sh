#
# Deploy Registry Console
#
oc new-app -n default --template=registry-console -p \
OPENSHIFT_OAUTH_PROVIDER_URL="https://komizo-openshift33.japanwest.cloudapp.azure.com:8443",REGISTRY_HOST=$(oc get route registry-console -n default --template='{{ .spec.host }}'),COCKPIT_KUBE_URL=$(oc get route registry-console -n default --template='https://{{ .spec.host }}')
