#!/usr/bin/env bash

APISERVER=https://kubernetes.default.svc
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
NAMESPACE=$(cat ${SERVICEACCOUNT}/namespace)
TOKEN=$(cat ${SERVICEACCOUNT}/token)
CACERT=${SERVICEACCOUNT}/ca.crt

basedir=$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)

rm -rf /tmp/installer
mkdir -p /tmp/installer
cd /tmp/installer

kubectl exec "$(kubectl get pod -l app=mtk-connect -n ${NAMESPACE} -o name | sed 's@^pod/@@')" -n ${NAMESPACE} -c portal -- find /usr/src/artifacts -name "mtk-connect-agent.*" -exec rm {} \;
declare -a architectures=("amd64" "arm" "arm64" "node" "win" "mac" "linux")
for architecture in "${architectures[@]}"; do
  image="${REGISTRY}/mtk-connect-agent-${architecture}-installer:${AGENT_VERSION}"
  if [ "${architecture}" == "node" ]; then
    installer="mtk-connect-agent.${AGENT_VERSION}.${architecture}.zip"
  elif [ "${architecture}" == "win" ]; then
    installer="mtk-connect-agent.${AGENT_VERSION}.${architecture}.exe"
  else
    installer="mtk-connect-agent.${AGENT_VERSION}.${architecture}.run"
  fi
  skopeo sync --src docker --dest dir --scoped "${image}" .
  layer=$(jq ".layers[].digest" <"${image}/manifest.json" | sed 's/sha256://' | sed 's/"//g')
  tar -xf "${image}/${layer}"
  kubectl cp "${installer}" "$(kubectl get pod -l app=mtk-connect -n ${NAMESPACE} -o name | sed 's@^pod/@@')":/usr/src/artifacts -n ${NAMESPACE} -c portal
done

kubectl exec "$(kubectl get pod -l app=mtk-connect -n ${NAMESPACE} -o name | sed 's@^pod/@@')" -n ${NAMESPACE} -c portal -- find /usr/src/artifacts -name "mtk-connect-tunnel.*" -exec rm {} \;
declare -a architectures=("node" "win" "mac" "linux")
for architecture in "${architectures[@]}"; do
  image="${REGISTRY}/mtk-connect-tunnel-${architecture}-installer:${TUNNEL_VERSION}"
  if [ "${architecture}" == "node" ]; then
    installer="mtk-connect-tunnel.${TUNNEL_VERSION}.${architecture}.zip"
  elif [ "${architecture}" == "win" ]; then
    installer="mtk-connect-tunnel.${TUNNEL_VERSION}.${architecture}.exe"
  else
    installer="mtk-connect-tunnel.${TUNNEL_VERSION}.${architecture}.run"
  fi
  skopeo sync --src docker --dest dir --scoped "${image}" .
  layer=$(jq ".layers[].digest" <"${image}/manifest.json" | sed 's/sha256://' | sed 's/"//g')
  tar -xf "${image}/${layer}"
  kubectl cp "${installer}" "$(kubectl get pod -l app=mtk-connect -n ${NAMESPACE} -o name | sed 's@^pod/@@')":/usr/src/artifacts -n ${NAMESPACE} -c portal
done

kubectl exec "$(kubectl get pod -l app=mtk-connect -n ${NAMESPACE} -o name | sed 's@^pod/@@')" -n ${NAMESPACE} -c portal -- find /usr/src/artifacts -name "mtk-connect-guacd.*" -exec rm {} \;
declare -a architectures=("amd64" "arm" "arm64")
for architecture in "${architectures[@]}"; do
  image="${REGISTRY}/mtk-connect-guacd-${architecture}-installer:${GUACD_VERSION}"
  installer="mtk-connect-guacd.${GUACD_VERSION}.${architecture}.run"
  skopeo sync --src docker --dest dir --scoped "${image}" .
  layer=$(jq ".layers[].digest" <"${image}/manifest.json" | sed 's/sha256://' | sed 's/"//g')
  tar -xf "${image}/${layer}"
  kubectl cp "${installer}" "$(kubectl get pod -l app=mtk-connect -n ${NAMESPACE} -o name | sed 's@^pod/@@')":/usr/src/artifacts -n ${NAMESPACE} -c portal
done

cd /root
MTKC_APIKEY=$(kubectl exec "$(kubectl get pod -l app=mtk-connect -n ${NAMESPACE} -o name | sed 's@^pod/@@')" -n ${NAMESPACE} -c authenticator -- node createServiceAccount.js mtk-connect-admin)

if [ $? -eq 0 ]; then
  sed -i "s/##MTKC_APIKEY##/${MTKC_APIKEY}/g" ./secret-jenkins.json
  sed -i "s/##MTKC_APIKEY##/${MTKC_APIKEY}/g" ./secret-mtk-connect.json

  curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X DELETE ${APISERVER}/api/v1/namespaces/jenkins/secrets/jenkins-mtk-connect-apikey
  curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -H 'Accept: application/json' -H 'Content-Type: application/json' -X POST ${APISERVER}/api/v1/namespaces/jenkins/secrets -d @secret-jenkins.json

  curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X DELETE ${APISERVER}/api/v1/namespaces/mtk-connect/secrets/mtk-connect-apikey
  curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -H 'Accept: application/json' -H 'Content-Type: application/json' -X POST ${APISERVER}/api/v1/namespaces/mtk-connect/secrets -d @secret-mtk-connect.json
fi
