#!/usr/bin/env bash

APISERVER=https://kubernetes.default.svc
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
NAMESPACE=$(cat ${SERVICEACCOUNT}/namespace)
TOKEN=$(cat ${SERVICEACCOUNT}/token)
CACERT=${SERVICEACCOUNT}/ca.crt

npm install
node keycloak.mjs
SECRET=$(cat client-gerrit.json | jq -r ".secret")

ssh-keygen -t ecdsa -b 256 -f ./id_ecdsa -C "horizon-sdv" -N "" -q
SSH_KEY=$(cat id_ecdsa | base64 -w0)
SSH_KEY_PUB=$(cat id_ecdsa.pub | base64 -w0)

sed -i "s/##SECRET##/${SECRET}/g" ./secure.config
SECURE_CONFIG=$(cat secure.config | base64 -w0)

sed -i "s/##SECURE_CONFIG##/${SECURE_CONFIG}/g" ./secret.json
sed -i "s/##SSH_KEY##/${SSH_KEY}/g" ./secret.json
sed -i "s/##SSH_KEY_PUB##/${SSH_KEY_PUB}/g" ./secret.json

curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X DELETE ${APISERVER}/api/v1/namespaces/gerrit/secrets/gerrit-secure-config
curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -H 'Accept: application/json' -H 'Content-Type: application/json' -X POST ${APISERVER}/api/v1/namespaces/gerrit/secrets -d @secret.json
