#!/usr/bin/env bash

# Copyright (c) 2024 Accenture, All Rights Reserved.
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
# Common functions and variables for use with AAOS build scripts.
#
# The following variables must be set before running this script:
#
#  - AAOS_GERRIT_MANIFEST_URL: the URL of the AAOS manifest.
#  - AAOS_REVISION: the branch or tag/version of the AAOS manifest.
#  - AAOS_LUNCH_TARGET: the target device.
#
# Optional variables:
#  - AAOS_CLEAN_BUILD: whether to clean the build directory before building.
#  - AAOS_ARTIFACT_STORAGE_SOLUTION: the persistent storage location for
#         artifacts (GCS_BUCKET default).
#
# For Gerrit review change sets:
#  - GERRIT_PROJECT: the name of the project to download.
#  - GERRIT_CHANGE_NUMBER: the change number of the changeset to download.
#  - GERRIT_PATCHSET_NUMBER: the patchset number of the changeset to download.
#
#  Jenkins Global node properties, configured as code:
#  - CLOUD_PROJECT: the GCP project ID, eg. sdvc-2108202401
#  - CLOUD_REGION: the GCP project location, eg. europe-west1
#  - ANDROID_BUILD_DOCKER_ARTIFACT_PATH_NAME: Docker artifact path

# Store BUILD_NUMBER for path in aaos_storage.sh
# shellcheck disable=SC2034
AAOS_BUILD_NUMBER=${AAOS_BUILD_NUMBER:-${BUILD_NUMBER}}
JOB_NAME=${JOB_NAME:-aaos}

# Android rebuilds if Jenkins BUILD_NUMBER / HOSTNAME change.
# New job will always have new number and agent name changes.
# unset Jenkins BUILD_NUMBER and BUILD_HOSTNAME to keep rebuilds
# minimal.
unset BUILD_NUMBER
# BUILD_HOSTNAME is defined by Android from hostname. Jenkinsfile now
# defines a fixed hostname for the agent.

# AAOS revisions: qpr1 for AVD etc, r22 for RPi HW.
AAOS_DEFAULT_REVISION=${AAOS_DEFAULT_REVISION:-android14-qpr1-automotiveos-release}
AAOS_RPI_REVISION=${AAOS_RPI_REVISION:-android-14.0.0_r22}

# Android branch/tag:
AAOS_REVISION=${AAOS_REVISION:-${AAOS_DEFAULT_REVISION}}
AAOS_REVISION=$(echo "${AAOS_REVISION}" | xargs)

# Gerrit AAOS and RPi manifest URLs.
AAOS_GERRIT_MANIFEST_URL=${AAOS_GERRIT_MANIFEST_URL:-https://android.googlesource.com/platform/manifest}
AAOS_GERRIT_RPI_MANIFEST_URL=${AAOS_GERRIT_RPI_MANIFEST_URL:-https://raw.githubusercontent.com/raspberry-vanilla/android_local_manifest/}

# Check we have a target defined.
AAOS_LUNCH_TARGET=$(echo "${AAOS_LUNCH_TARGET}" | xargs)
# Default if not defined (important for initial pipeline build)
AAOS_LUNCH_TARGET=${AAOS_LUNCH_TARGET:-sdk_car_x86_64-userdebug}
if [ -z "${AAOS_LUNCH_TARGET}" ]; then
    echo "Error: please define AAOS_LUNCH_TARGET"
    exit 255
fi

# Cache directory
AAOS_CACHE_DIRECTORY=${AAOS_CACHE_DIRECTORY:-/aaos-cache}

# AAOS workspace and artifact storage paths
if [ -z "${WORKSPACE}" ]; then
    WORKSPACE="${HOME}"/aaos_builds
else
    # Ensure PVC has correct privileges.
    # Note: builder Dockerfile defines USER name
    sudo chown builder:builder /"${AAOS_CACHE_DIRECTORY}"
    sudo chmod g+s /"${AAOS_CACHE_DIRECTORY}"

    WORKSPACE=/"${AAOS_CACHE_DIRECTORY}"/aaos_builds
    if [[ "${AAOS_LUNCH_TARGET}" =~ "rpi" ]]; then
        # Avoid RPI builds affecting standard android repos.
        WORKSPACE=/"${AAOS_CACHE_DIRECTORY}"/aaos_builds_rpi
    fi
fi

# Clean build - remove workspace.
if [[ "${AAOS_CLEAN_BUILD}" -eq 1 ]]; then
    echo "Clean workspace ${WORKSPACE} ..."
    rm -rf "${WORKSPACE}" > /dev/null 2>&1
    echo "Cleaned workspace ${WORKSPACE}."
fi

mkdir -p "${WORKSPACE}" > /dev/null 2>&1
cd "${WORKSPACE}" || exit

# Architecture:
AAOS_ARCH=""
if [[ "${AAOS_LUNCH_TARGET}" =~ "arm64" ]]; then
    AAOS_ARCH="arm64"
elif [[ "${AAOS_LUNCH_TARGET}" =~ "x86_64" ]]; then
    AAOS_ARCH="x86_64"
elif [[ "${AAOS_LUNCH_TARGET}" =~ "rpi4" ]]; then
    AAOS_ARCH="rpi4"
elif [[ "${AAOS_LUNCH_TARGET}" =~ "rpi5" ]]; then
    AAOS_ARCH="rpi5"
fi

# Declare articact array.
declare -a AAOS_ARTIFACT_LIST

# Define the make command line for given target
AAOS_MAKE_CMDLINE=""

# If Jenkins, or local, the artifacts differ so update.
USER=$(whoami)
IMAGE_EXT=${BUILD_NUMBER:-eng.$USER}

# This is a dictionary mapping the target names to the command line
# to build the image.
case "${AAOS_LUNCH_TARGET}" in
    aosp_rpi*)
        AAOS_MAKE_CMDLINE="m bootimage systemimage vendorimage"
        # FIXME: we can build full flashable image but may require special
        # permissions, for now host the individual parts.
        # ${VERSION}-${DATE}-rpi5.img # rpi5-mkimg.sh
        AAOS_ARTIFACT_LIST=(
            "out/target/product/${AAOS_ARCH}/boot.img"
            "out/target/product/${AAOS_ARCH}/system.img"
            "out/target/product/${AAOS_ARCH}/vendor.img"
        )
        ;;
    sdk_car*)
        AAOS_MAKE_CMDLINE="m && m emu_img_zip && m sbom"
        AAOS_ARTIFACT_LIST=(
            "out/target/product/emulator_car64_${AAOS_ARCH}/sbom.spdx.json"
            "out/target/product/emulator_car64_${AAOS_ARCH}/sdk-repo-linux-system-images-${IMAGE_EXT}.zip"
        )
        ;;
    aosp_cf*)
        AAOS_MAKE_CMDLINE="m dist"
        AAOS_ARTIFACT_LIST=(
            "out/dist/cvd-host_package.tar.gz"
            "out/dist/sbom/sbom.spdx.json"
            "out/dist/aosp_cf_${AAOS_ARCH}_auto-img-${IMAGE_EXT}.zip"
        )
        # If the AAOS_BUILD_CTS variable is set, build only the cts image.
        if [[ "$AAOS_BUILD_CTS" -eq 1 ]]; then
            AAOS_MAKE_CMDLINE="m cts -j16"
            AAOS_ARTIFACT_LIST=("out/host/linux-x86/cts/android-cts.zip")
        fi
        ;;
    *)
        # If the target is not one of the above, print an error message
        # but continue as best so people can play with builds.
        echo "Error: unknown target ${LUNCH_TARGET}" >&2
        AAOS_MAKE_CMDLINE="m"
        echo "Defaulting make to: ${AAOS_MAKE_CMDLINE}"
        echo "Artifacts will not be stored!"
        ;;
esac

# Define artifact storage strategy and functions.
AAOS_ARTIFACT_STORAGE_SOLUTION=${AAOS_ARTIFACT_STORAGE_SOLUTION:-"GCS_BUCKET"}
AAOS_ARTIFACT_STORAGE_SOLUTION=$(echo "${AAOS_ARTIFACT_STORAGE_SOLUTION}" | xargs)

# Artifact storage bucket
AAOS_ARTIFACT_ROOT_NAME=${AAOS_ARTIFACT_ROOT_NAME:-aaos_builds}
AAOS_ARTIFACT_REGION=${CLOUD_REGION:-europe-west1}

# Gerrit Review environment variables: remove leading and trailing slashes.
GERRIT_PROJECT=$(echo "${GERRIT_PROJECT}" | xargs)
GERRIT_CHANGE_NUMBER=$(echo "${GERRIT_CHANGE_NUMBER}" | xargs)
GERRIT_PATCHSET_NUMBER=$(echo "${GERRIT_PATCHSET_NUMBER}" | xargs)

# Show variables.
VARIABLES="
Environment:
    AAOS_GERRIT_MANIFEST_URL=${AAOS_GERRIT_MANIFEST_URL}
    AAOS_GERRIT_RPI_MANIFEST_URL=${AAOS_GERRIT_RPI_MANIFEST_URL}

    AAOS_LUNCH_TARGET=${AAOS_LUNCH_TARGET}
    AAOS_REVISION=${AAOS_REVISION}
    AAOS_RPI_REVISION=${AAOS_RPI_REVISION}
    AAOS_ARCH=${AAOS_ARCH}
    AAOS_MAKE_CMDLINE=${AAOS_MAKE_CMDLINE}

    hostname=$(hostname)

    WORKSPACE=${WORKSPACE}

    AAOS_ARTIFACT_STORAGE_SOLUTION=${AAOS_ARTIFACT_STORAGE_SOLUTION}
    AAOS_ARTIFACT_ROOT_NAME=${AAOS_ARTIFACT_ROOT_NAME}
    AAOS_ARTIFACT_REGION=${AAOS_ARTIFACT_REGION}

    GERRIT_PROJECT=${GERRIT_PROJECT}
    GERRIT_CHANGE_NUMBER=${GERRIT_CHANGE_NUMBER}
    GERRIT_PATCHSET_NUMBER=${GERRIT_PATCHSET_NUMBER}

    Storage Usage (${AAOS_CACHE_DIRECTORY}): $(df -h "${AAOS_CACHE_DIRECTORY}" | tail -1 | awk '{print "Used " $3 " of " $2}')
   "
echo "${VARIABLES}"
