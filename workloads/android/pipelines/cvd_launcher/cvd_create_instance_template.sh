#!/usr/bin/env bash

# Copyright (c) 2024 Accenture, All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Description:
# Create the Cuttlefish boilerplate template instance for use with Jenkins
# GCE plugin and running Cuttlefish standalone or with CTS.
#
# To run, ensure gcloud is set up, authenticated and tunneling is
# configured, eg. --tunnel-through-iap.
#
# From command line, such as Google Cloud Shell, create templates for all
# versions of android-cuttlefish host tools/packages:
#
# CUTTLEFISH_REVISION=v0.9.29 ./cvd_create_instance_template.sh && \
#  CUTTLEFISH_REVISION=v0.9.30 ./cvd_create_instance_template.sh && \
#  CUTTLEFISH_REVISION=v0.9.31 ./cvd_create_instance_template.sh && \
#  ./cvd_create_instance_template.sh # for main
#
# The following variables are required to run the script, choose to use
# default values or override from command line.
#
#  - CUTTLEFISH_REVISION: the branch/tag version of Android Cuttlefish
#        to use. Default: main
#  - BOOT_DISK_SIZE: Disk image size in GB. Default: 200GB
#  - MACHINE_TYPE: The machine type to create instance templates for. Default:
#        n1-standard-64
#  - NETWORK: The name of the VPC network. Default: sdv-network
#  - PROJECT: The GCP project. Default: derived from gcloud config.
#  - REGION: The GCP region. Default: europe-west1
#  - SERVICE_ACCOUNT: The GCP service account. Default: derived from gcloud
#        projects describe.
#  - SUBNET: The name of the subnet. Default: sdv-subnet
#  - ZONE: The GCP zone. Default: europe-west1-d
#
# The following arguments are optional and recommended run without args:

#  -h|--help :     - Print usage
#  1 : Run stage 1 - create the base instance template (debian 12 +
#                    virtualisation)
#  2 : Run stage 2 - create the VM instance from base instance template.
#  3 : Run stage 3 - Populate the VM instance with CF host packages
#                    and other dependent packages.
#                    Create 'jenkins' user and groups.
#                    Add CF groups to jenkins account.
#  4 : Run stage 4 - Create the SSH key for Jenkins account if key is not
#                    available, and store public key as authorized_key for
#                    Jenkins account. If key exists, reuse the existing public
#                    key.
#  5 : Run stage 5 - Stop the VM instance that is now configured for CF.
#                    Create a boot disk image of that VM instance.
#                    Create Cuttlefish instance template from that boot disk
#                    image.
#                    Create the Cuttlefish VM instance and stop that instance.
#                    The instance template is what GCE Plugin uses, the VM
#                    instance is purely created for reference.
#  No args:          run all stages.

# Include common functions and variables.
# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")"/cvd_environment.sh "$0"

# Environment variables that can be overridden from command line.
# android-cuttlefish revisions can be v0.9.29, v0.9.30, v0.9.31, main
CUTTLEFISH_REVISION=${CUTTLEFISH_REVISION:-main}
BOOT_DISK_SIZE=${BOOT_DISK_SIZE:-200GB}
MACHINE_TYPE=${MACHINE_TYPE:-n1-standard-64}
NETWORK=${NETWORK:-sdv-network}
PROJECT=${PROJECT:-$(gcloud config list --format 'value(core.project)'|head -n 1)}
REGION=${REGION:-europe-west1}
SERVICE_ACCOUNT=${SERVICE_ACCOUNT:-$(gcloud projects describe "${PROJECT}" --format='get(projectNumber)')-compute@developer.gserviceaccount.com}
SUBNET=${SUBNET:-sdv-subnet}
ZONE=${ZONE:-europe-west1-d}

# Instance names can only include specific characters, drop '.'.
declare -r cuttlefish_version=${CUTTLEFISH_REVISION//./}
declare -r vm_base_instance_template=instance-template-vm-debian-12
declare -r vm_base_instance=vm-debian-12
declare -r vm_cuttlefish_image=image-cuttlefish-vm-"${cuttlefish_version}"-debian-12
declare -r vm_cuttlefish_instance_template=instance-template-cuttlefish-vm-"${cuttlefish_version}"-debian-12
declare -r vm_cuttlefish_instance=cuttlefish-vm-${cuttlefish_version}-debian-12

# Colours for logging.
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'
SCRIPT_NAME=$(basename "$0")

# Catch Ctrl+C and terminate all
trap terminate SIGINT
function terminate() {
    echo -e "${RED}CTRL+C: exit requested!${NC}"
    exit 1
}

# Progress spinner. Wait for PID to complete.
function progress_spinner() {
    local -r spinner='-\|/'
    while sleep 0.1; do
        i=$(( (i+1) %4 ))
        # shellcheck disable=SC2059
        printf "\r${spinner:$i:1}"
        if ! ps -p "$1" > /dev/null; then
            break
        fi
    done
    printf "\r"
    wait "${1}"
}

# Echo formatted output.
function echo_formatted() {
    echo -e "\r${GREEN}[$SCRIPT_NAME] $1${NC}"
}

# Echo environment variables.
function echo_environment() {
    echo_formatted "Environment variables:"
    echo_formatted "CUTTLEFISH_REVISION=${CUTTLEFISH_REVISION}"
    echo_formatted "BOOT_DISK_SIZE=${BOOT_DISK_SIZE}"
    echo_formatted "MACHINE_TYPE=${MACHINE_TYPE}"
    echo_formatted "NETWORK=${NETWORK}"
    echo_formatted "PROJECT=${PROJECT}"
    echo_formatted "REGION=${REGION}"
    echo_formatted "SERVICE_ACCOUNT=${SERVICE_ACCOUNT}"
    echo_formatted "SUBNET=${SUBNET}"
    echo_formatted "ZONE=${ZONE}"
}

function print_usage() {
    echo "Usage:
      CUTTLEFISH_REVISION=${CUTTLEFISH_REVISION} \\
      BOOT_DISK_SIZE=${BOOT_DISK_SIZE} \\
      MACHINE_TYPE=${MACHINE_TYPE} \\
      NETWORK=${NETWORK} \\
      PROJECT=${PROJECT} \\
      REGION=${REGION} \\
      SERVICE_ACCOUNT=${SERVICE_ACCOUNT} \\
      SUBNET=${SUBNET} \\
      ZONE=${ZONE} \\
      ./${SCRIPT_NAME}"
    echo "Use defaults or override environment variables."
}

# Function to check if running locally to avoid downloading CTS archives
# that cause MS Defender to block MacOS because of CTS vulnerabilities.
function check_environment() {
    if [ -z "${PROJECT}" ]; then
        echo -r "${RED}Environment variable PROJECT must be defined${NC}"
        exit 1
    fi
    if [ -z "${SERVICE_ACCOUNT}" ]; then
        echo -r "${RED}Environment variable SERVICE_ACCOUNT must be defined${NC}"
        exit 1
    fi
}

# Create the initial template boot disk
function create_base_template_instance() {
    echo_formatted "1. Create base template"
    yes Y | gcloud compute instance-templates delete "${vm_base_instance_template}" >/dev/null 2>&1 || true
    gcloud compute instance-templates create "${vm_base_instance_template}" \
        --description="Instance template: ${vm_base_instance_template}" \
        --shielded-integrity-monitoring \
        --key-revocation-action-type=none \
        --service-account="${SERVICE_ACCOUNT}" \
        --machine-type="${MACHINE_TYPE}" \
        --image-project=debian-cloud \
        --create-disk=mode=rw,architecture=X86_64,boot=yes,size="${BOOT_DISK_SIZE}",auto-delete=true,type=pd-balanced,device-name="${vm_base_instance}",image=projects/debian-cloud/global/images/debian-12-bookworm-v20241009,interface=SCSI \
        --tags=http-server,https-server \
        --metadata=enable-oslogin=true \
        --reservation-affinity=any \
        --enable-nested-virtualization \
        --region="${REGION}" \
        --network-interface=network="${NETWORK}",subnet="${SUBNET}",stack-type=IPV4_ONLY,no-address >/dev/null 2>&1 &
    progress_spinner "$!"
    echo -e "${ORANGE}Instance template ${vm_base_instance_template} created${NC}"
}

# Create a VM instance from the base tenplate instance.
function create_vm_instance() {
    echo_formatted "2. Create VM Instance from base template"
    yes Y | gcloud compute instances delete "${vm_base_instance}" \
        --zone="${ZONE}" >/dev/null 2>&1 || true &
    progress_spinner "$!"

    gcloud compute instances create "${vm_base_instance}" \
        --source-instance-template "${vm_base_instance_template}" \
        --zone="${ZONE}" >/dev/null 2>&1 &
    progress_spinner "$!"

    echo -e "${ORANGE}Sleep for 2 minutes while instance stabilises${NC}"
    sleep 120
    echo -e "${ORANGE}VM Instance ${vm_base_instance} created${NC}"
}

# Install host tools on the base VM instance.
# Host will reboot when installed (see cvd_initialise.sh)
function install_host_tools() {
    echo_formatted "3. Populate Cuttlefish Host tools/packages on VM instance"

    gcloud compute ssh --zone "${ZONE}" "${vm_base_instance}" --tunnel-through-iap --project "${PROJECT}" \
        --command='mkdir -p cvd' >/dev/null 2>&1 &
    progress_spinner "$!"

    gcloud compute scp ./*.sh  "${vm_base_instance}":~/cvd/ --zone="${ZONE}" >/dev/null 2>&1 &
    progress_spinner "$!"

    # Keep debug so we can see what's happening.
    gcloud compute ssh --zone "${ZONE}" "${vm_base_instance}" --tunnel-through-iap --project "${PROJECT}" \
        --command="CUTTLEFISH_REVISION=${CUTTLEFISH_REVISION} ./cvd/cvd_initialise.sh"  &
    progress_spinner "$!"

    gcloud compute ssh --zone "${ZONE}" "${vm_base_instance}" --tunnel-through-iap --project "${PROJECT}" \
        --command='rm -rf cvd' > /dev/null 2>&1 &
    progress_spinner "$!"

    echo -e "${ORANGE}Sleep for 5 minutes while instance reboots${NC}"
    sleep 300
    echo -e "${ORANGE}VM instance ${vm_base_instance} rebooted!${NC}"
}

# Add SSH key for Jenkins.
# - Ensure the private key is added to Jenkins credentials that are
#   used for GCE plugin and SSH for Cuttlefish template instances.
function create_ssh_key() {
    echo_formatted "4. Create jenkins SSH Key on VM instance"

    # Generate the key if it doesn't exist locally
    if ! [ -f jenkins_rsa.pub ]; then
        echo "Generating Jenkins SSH Key"
        ssh-keygen -t rsa -b 4096 -C "jenkins" -f jenkins_rsa -q -N ""
        echo -e "${RED}START: COPY PRIVATE KEY TO JENKINS CREDENTIALS${NC}"
        cat jenkins_rsa
        echo -e "${RED}END: COPY PRIVATE KEY TO JENKINS CREDENTIALS${NC}"
    else
        echo -e "${ORANGE}Jenkins SSH Key already exists, reusing${NC}"
    fi

    gcloud compute ssh --zone "${ZONE}" "${vm_base_instance}" --tunnel-through-iap \
        --project "${PROJECT}" \
        --command='sudo  rm -rf /home/jenkins/.ssh && sudo mkdir /home/jenkins/.ssh && sudo chmod 700 /home/jenkins/.ssh && sudo chown jenkins:jenkins /home/jenkins/.ssh' >/dev/null 2>&1 &
    progress_spinner "$!"

    gcloud compute scp jenkins_rsa.pub  "${vm_base_instance}":/tmp/authorized_keys --zone="${ZONE}" >/dev/null 2>&1 &
    progress_spinner "$!"

    gcloud compute ssh --zone "${ZONE}" "${vm_base_instance}" --tunnel-through-iap --project "${PROJECT}" \
        --command='sudo mv /tmp/authorized_keys /home/jenkins/.ssh/authorized_keys && sudo chown -R jenkins:jenkins /home/jenkins/.ssh' >/dev/null 2>&1 &
    progress_spinner "$!"
}

# Create the final Cuttlefish template for use with Jenkins GCE plugin
# allowing Cuttlefish to run on the Jenkins VM Instance.
function create_cuttlefish_boilerplate_template() {
    echo_formatted "5. Create Cuttlefish boilerplate template instance from VM Instance"
    gcloud compute instances stop "${vm_base_instance}" --zone="${ZONE}" >/dev/null 2>&1 || true &
    progress_spinner "$!"

    yes Y | gcloud compute images delete "${vm_cuttlefish_image}"  >/dev/null 2>&1 || true &
    progress_spinner "$!"

    echo -e "${ORANGE}Sleep for 1 minute while image deletion completes${NC}"
    sleep 60

    gcloud compute images create "${vm_cuttlefish_image}" \
        --source-disk="${vm_base_instance}" \
        --source-disk-zone="${ZONE}" \
        --storage-location="${REGION}" \
        --source-disk-project="${PROJECT}" >/dev/null 2>&1 &
    progress_spinner "$!"

    echo -e "${ORANGE}Sleep for 1 minute while image creation completes${NC}"
    sleep 60
    echo -e "${ORANGE}Image ${vm_cuttlefish_image} created${NC}"

    yes Y | gcloud compute instances delete "${vm_base_instance}" \
        --zone="${ZONE}" >/dev/null 2>&1 || true &
    progress_spinner "$!"

    echo -e "${ORANGE}Sleep for 1 minute while instance deletion completes${NC}"
    sleep 60

    yes Y | gcloud compute instance-templates delete "${vm_cuttlefish_instance_template}" > /dev/null 2>&1 || true &
    progress_spinner "$!"

    echo -e "${ORANGE}Sleep for 1 minute while instance template deletion completes${NC}"
    sleep 60

    gcloud compute instance-templates create "${vm_cuttlefish_instance_template}" \
        --description="${vm_cuttlefish_instance_template}" \
        --shielded-integrity-monitoring \
        --key-revocation-action-type=none \
        --service-account="${SERVICE_ACCOUNT}" \
        --machine-type="${MACHINE_TYPE}" \
        --image-project=debian-cloud \
        --create-disk=image="${vm_cuttlefish_image}",boot=yes,auto-delete=yes \
        --metadata=enable-oslogin=true \
        --reservation-affinity=any \
        --enable-nested-virtualization \
        --region="${REGION}" \
        --network-interface network="${NETWORK}",subnet="${SUBNET}",stack-type=IPV4_ONLY,no-address  >/dev/null 2>&1 &
    progress_spinner "$!"

    echo -e "${ORANGE}Sleep for 1 minute while instance template creation completes${NC}"
    sleep 60
    echo -e "${ORANGE}Instance Template ${vm_cuttlefish_instance_template} created${NC}"

    # Delete and Recreate a VM instance for local tests.
    yes Y | gcloud compute instances delete "${vm_cuttlefish_instance}" \
        --zone="${ZONE}" >/dev/null 2>&1 || true &
    progress_spinner "$!"

    gcloud compute instances create "${vm_cuttlefish_instance}" \
        --source-instance-template "${vm_cuttlefish_instance_template}" \
        --zone="${ZONE}" > /dev/null 2>&1 &
    progress_spinner "$!"

    echo -e "${ORANGE}Sleep for 1 minute while instance creation completes${NC}"
    sleep 60
    echo -e "${ORANGE}VM Instance ${vm_cuttlefish_instance} created${NC}"

    # Delete the base template
    yes Y | gcloud compute instance-templates delete "${vm_base_instance_template}" >/dev/null 2>&1 || true
    progress_spinner "$!"

    # Stop the VM instance.
    gcloud compute instances stop "${vm_cuttlefish_instance}" --zone="${ZONE}" >/dev/null 2>&1 || true &
    progress_spinner "$!"
}

# Main: run all or allow the user to select which steps to run.
function main() {
    echo_environment
    case $1 in
        1) create_base_template_instance ;;
        2) create_vm_instance ;;
        3) install_host_tools ;;
        4) create_ssh_key ;;
        5) create_cuttlefish_boilerplate_template ;;
        *h*)
            print_usage
            exit 0
            ;;
        *) 
            create_base_template_instance
            create_vm_instance
            install_host_tools
            create_ssh_key
            create_cuttlefish_boilerplate_template
            echo_formatted "Done. Please check the output above and enjoy Cuttlefish!"
            ;;
    esac
}

main "$1"
