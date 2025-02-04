#!/bin/bash

CLOUD_REGION=europe-west1
CLUSTER_NAME="sdv-cluster"
REPOSITORY=github.com/AGBG-ASG/acn-horizon-sdv

touch ~/terraform-log.log
echo $(date) >>~/terraform-log.log
cat ~/terraform-log.log

echo ""
echo "Updating Debian APT"
export DEBIAN_FRONTEND=noninteractive
sudo apt update && sudo apt upgrade -y

echo ""
echo "Updating Debian APT"
sudo apt install -y git docker.io kubectl google-cloud-cli-gke-gcloud-auth-plugin
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg >/dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt install -y helm
gcloud container clusters get-credentials sdv-cluster --region ${CLOUD_REGION}

echo ""
echo "Helm Version"
helm version

echo ""
echo "Install Helm Diff plugin"
helm plugin install https://github.com/databus23/helm-diff

echo ""
echo "Kubectl Version"
kubectl version

echo ""
echo "docker version"
sudo docker version

echo ""
echo "Gcloud Info"
gcloud info

echo ""
echo "Connecting to Kubernetes"
gcloud container clusters get-credentials ${CLUSTER_NAME} --region ${CLOUD_REGION}

echo ""
echo "List $SDV_CLUSTER_NAME nodes"
kubectl get nodes

echo ""
echo "Adding the current user to the docker group"
echo "sudo usermod -aG docker $USER"
sudo usermod -aG docker $USER

echo ""
echo "Docker configurations"
gcloud auth configure-docker ${CLOUD_REGION}-docker.pkg.dev --quiet
cat ~/.docker/config.json

echo ""
echo "Removing old project"
rm -rf ~/horizon-sdv

echo ""
echo "Cloning github project"
git clone https://x-access-token:${GITHUB_ACCESS_TOKEN}@${REPOSITORY} ~/horizon-sdv

echo ""
echo "List current branch and remote"
cd ~/horizon-sdv
git checkout -t origin/env/sbx

echo ""
echo "Build config post jobs"
cd ~/horizon-sdv/gitops/env/stage2/configs
chmod +x ./build.sh
./build.sh

echo ""
echo "Run stage1 deployment"
cd ~/horizon-sdv/gitops/env/stage1
chmod +x ./deploy.sh
./deploy.sh
