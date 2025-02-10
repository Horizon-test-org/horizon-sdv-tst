#!/bin/bash

CLOUD_REGION=europe-west1
PROJECT_ID=sdvd-0502202501
VERSION=1.0.0

declare -a configs=("gerrit-post" "mtk-connect-post" "keycloak-post" "keycloak-post-gerrit" "keycloak-post-jenkins" "keycloak-post-mtk-connect")
substr="-post"
for config in "${configs[@]}"; do
  docker build -t ${CLOUD_REGION}-docker.pkg.dev/${PROJECT_ID}/horizon-sdv/${config}:${VERSION} ${config%$substr*}/${config}
  docker push ${CLOUD_REGION}-docker.pkg.dev/${PROJECT_ID}/horizon-sdv/${config}:${VERSION}
done
