#!/usr/bin/env bash

APISERVER=https://kubernetes.default.svc
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
NAMESPACE=$(cat ${SERVICEACCOUNT}/namespace)
TOKEN=$(cat ${SERVICEACCOUNT}/token)
CACERT=${SERVICEACCOUNT}/ca.crt

npm install
node keycloak.mjs

IDP_PEM=$(cat idpCert.pem | base64 -w0)
KEY_PEM=$(cat privateKey.pem | base64 -w0)

sed -i "s/##IDP_PEM##/${IDP_PEM}/g" ./secret.json
sed -i "s/##KEY_PEM##/${KEY_PEM}/g" ./secret.json

curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X DELETE ${APISERVER}/api/v1/namespaces/mtk-connect/secrets/mtk-connect-keycloak
curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -H 'Accept: application/json' -H 'Content-Type: application/json' -X POST ${APISERVER}/api/v1/namespaces/mtk-connect/secrets -d @secret.json
