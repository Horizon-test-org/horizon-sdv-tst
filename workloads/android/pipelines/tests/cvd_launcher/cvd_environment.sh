#!/usr/bin/env bash

# Copyright (c) 2024-2025 Accenture, All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Description:
# Common environment functions and variables for Cuttlefish Virtual Device
# (CVD).

# Android Cuttlefish Repository that holds supporting tools to prepare host
# to boot Cuttlefish.
CUTTLEFISH_REPO_URL=$(echo "${CUTTLEFISH_REPO_URL}" | xargs)
CUTTLEFISH_REPO_URL=${CUTTLEFISH_REPO_URL:-https://github.com/google/android-cuttlefish.git}
CUTTLEFISH_REVISION=${CUTTLEFISH_REVISION:-main}
CUTTLEFISH_REPO_NAME=$(basename "${CUTTLEFISH_REPO_URL}" .git)
# Must use flag because there is inconsistency between tag/branch and dpkg
# version number, eg main = 1.0.0.
CUTTLEFISH_UPDATE=${CUTTLEFISH_UPDATE:-false}
# Time (seconds) to wait for Virtual Device to boot.
CUTTLEFISH_MAX_BOOT_TIME=$(echo "${CUTTLEFISH_MAX_BOOT_TIME}" | xargs)
CUTTLEFISH_MAX_BOOT_TIME=${CUTTLEFISH_MAX_BOOT_TIME:-240}
# Time (minutes) to keep device alive.
CUTTLEFISH_KEEP_ALIVE_TIME=$(echo "${CUTTLEFISH_KEEP_ALIVE_TIME}" | xargs)
CUTTLEFISH_KEEP_ALIVE_TIME=${CUTTLEFISH_KEEP_ALIVE_TIME:-20}

# Android CTS test harness URLs, installed on host.
# https://source.android.com/docs/compatibility/cts/downloads
CTS_ANDROID_15_URL="https://dl.google.com/dl/android/cts/android-cts-15_r2-linux_x86-x86.zip"
CTS_ANDROID_14_URL="https://dl.google.com/dl/android/cts/android-cts-14_r6-linux_x86-x86.zip"
JOB_NAME=${JOB_NAME:-AAOS_CVD}

# NodeJS Version
NODEJS_VERSION=${NODEJS_VERSION:-20.9.0}

# Architecture x86_64 is only supported at this time.
ARCHITECTURE=${ARCHITECTURE:-x86_64}

# Download URL for artifacts.
CUTTLEFISH_DOWNLOAD_URL=$(echo "${CUTTLEFISH_DOWNLOAD_URL}" | xargs)
CUTTLEFISH_DOWNLOAD_URL=${CUTTLEFISH_DOWNLOAD_URL:-gs://sdva-2108202401-aaos/Android/Builds/AAOS_Builder/5}
# Strip any trailing slashes as this can impact on the download URL.
CUTTLEFISH_DOWNLOAD_URL=${CUTTLEFISH_DOWNLOAD_URL%/}

# Specific Cuttlefish Virtual Device and CTS variables.
NUM_INSTANCES=$(echo "${NUM_INSTANCES}" | xargs)
NUM_INSTANCES=${NUM_INSTANCES:-8}
VM_CPUS=$(echo "${VM_CPUS}" | xargs)
VM_CPUS=${VM_CPUS:-8}
VM_MEMORY_MB=$(echo "${VM_MEMORY_MB}" | xargs)
VM_MEMORY_MB=${VM_MEMORY_MB:-16384}

# Support local vs Jenkins.
if [ -z "${WORKSPACE}" ]; then
    CVD_PATH=../cvd_launcher
else
    CVD_PATH=workloads/android/pipelines/tests/cvd_launcher
fi

# Show variables.
VARIABLES="Environment:
        CTS_ANDROID_15_URL=${CTS_ANDROID_15_URL}
        CTS_ANDROID_14_URL=${CTS_ANDROID_14_URL}

        ARCHITECTURE=${ARCHITECTURE}
"

case "$0" in
    *create_instance_template.sh)
        VARIABLES+="
        CUTTLEFISH_REVISION=${CUTTLEFISH_REVISION}

        CVD_PATH=${CVD_PATH}
        "
        ;;
    *initialise.sh)
        VARIABLES+="
        CUTTLEFISH_REPO_URL=${CUTTLEFISH_REPO_URL}
        CUTTLEFISH_REPO_NAME=${CUTTLEFISH_REPO_NAME}
        CUTTLEFISH_REVISION=${CUTTLEFISH_REVISION}
        CUTTLEFISH_UPDATE=${CUTTLEFISH_UPDATE}
        "
        ;;
    *start_stop.sh)
        VARIABLES+="
        CUTTLEFISH_MAX_BOOT_TIME=${CUTTLEFISH_MAX_BOOT_TIME}
        CUTTLEFISH_KEEP_ALIVE_TIME=${CUTTLEFISH_KEEP_ALIVE_TIME}

        CUTTLEFISH_DOWNLOAD_URL=${CUTTLEFISH_DOWNLOAD_URL}

        NUM_INSTANCES=${NUM_INSTANCES} (--num_instances=${NUM_INSTANCES})
        VM_CPUS=${VM_CPUS} (--cpu ${VM_CPUS})
        VM_MEMORY_MB=${VM_MEMORY_MB} (--memory_mb ${VM_MEMORY_MB})
        "
        ;;
    *)
        ;;
esac

VARIABLES+="
        WORKSPACE=${WORKSPACE}

        /proc/cpuproc vmx: $(grep -cw vmx /proc/cpuinfo)

        Storage Usage (/dev/sda1): $(df -h /dev/sda1 | tail -1 | awk '{print "Used " $3 " of " $2}')
"

echo "${VARIABLES}"
