#!/usr/bin/env bash

APISERVER=https://kubernetes.default.svc
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
NAMESPACE=$(cat ${SERVICEACCOUNT}/namespace)
TOKEN=$(cat ${SERVICEACCOUNT}/token)
CACERT=${SERVICEACCOUNT}/ca.crt

npm install
node keycloak.mjs
SECRET=$(cat client-jenkins.json | jq -r ".secret")
DOMAIN_BS=$(echo $DOMAIN | sed 's:/:\\/:g')
sed -i "s/##DOMAIN##/${DOMAIN_BS}/g" ./secret.json
sed -i "s/##SECRET##/${SECRET}/g" ./secret.json

curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X DELETE ${APISERVER}/api/v1/namespaces/jenkins/secrets/jenkins-keycloak
curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -H 'Accept: application/json' -H 'Content-Type: application/json' -X POST ${APISERVER}/api/v1/namespaces/jenkins/secrets -d @secret.json
