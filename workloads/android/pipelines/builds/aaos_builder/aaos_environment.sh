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
# Common functions and variables for use with AAOS build scripts.
#
# The following variables must be set before running this script:
#
#  - AAOS_GERRIT_MANIFEST_URL: the URL of the AAOS manifest.
#  - AAOS_REVISION: the branch or tag/version of the AAOS manifest.
#  - AAOS_LUNCH_TARGET: the target device.
#  - OVERRIDE_MAKE_COMMAND: the make command line to use
#  - ADDITIONAL_INITIALISE_COMMANDS: additional vendor commands for initialisation.
#
# Optional variables:
#  - AAOS_CLEAN: whether to clean before building.
#  - AAOS_ARTIFACT_STORAGE_SOLUTION: the persistent storage location for
#         artifacts (GCS_BUCKET default).
#  - GERRIT_FETCH_PATCHSET: use FETCH vs repo download.
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
# defines a fixed hostname for the agent rather than using default
# agent hostname which changes per build and thus forcing Android
# rebuild. See:
# hostname: jenkins-aaos-build-pod

AAOS_DEFAULT_REVISION=$(echo "${AAOS_DEFAULT_REVISION}" | xargs)
AAOS_DEFAULT_REVISION=${AAOS_DEFAULT_REVISION:-android-14.0.0_r30}
AAOS_RPI_REVISION=$(echo "${AAOS_RPI_REVISION}" | xargs)
AAOS_RPI_REVISION=${AAOS_RPI_REVISION:-android-15.0.0_r4}

# Android branch/tag:
AAOS_REVISION=${AAOS_REVISION:-${AAOS_DEFAULT_REVISION}}
AAOS_REVISION=$(echo "${AAOS_REVISION}" | xargs)

# Gerrit AAOS and RPi manifest URLs.
AAOS_GERRIT_MANIFEST_URL=$(echo "${AAOS_GERRIT_MANIFEST_URL}" | xargs)
AAOS_GERRIT_MANIFEST_URL=${AAOS_GERRIT_MANIFEST_URL:-https://android.googlesource.com/platform/manifest}
AAOS_GERRIT_RPI_MANIFEST_URL=$(echo "${AAOS_GERRIT_RPI_MANIFEST_URL}" | xargs)
AAOS_GERRIT_RPI_MANIFEST_URL=${AAOS_GERRIT_RPI_MANIFEST_URL:-https://raw.githubusercontent.com/raspberry-vanilla/android_local_manifest/}

# Use FETCH for patchset rather than repo download.
GERRIT_FETCH_PATCHSET=${GERRIT_FETCH_PATCHSET:-true}
# Check we have a target defined.
AAOS_LUNCH_TARGET=$(echo "${AAOS_LUNCH_TARGET}" | xargs)
# Default if not defined (important for initial pipeline build)
AAOS_LUNCH_TARGET=${AAOS_LUNCH_TARGET:-sdk_car_x86_64-userdebug}
if [ -z "${AAOS_LUNCH_TARGET}" ]; then
    echo "Error: please define AAOS_LUNCH_TARGET"
    exit 255
fi

# Android Version
ANDROID_VERSION=${ANDROID_VERSION:-14}
case "${ANDROID_VERSION}" in
    15)
        ANDROID_API_LEVEL=35
        ;;
    *)
        # Deliberate fallthrough, 14 thus API level 34 minimum.
        ANDROID_API_LEVEL=34
        ;;
esac

# Adjust stat command for platform.
if [ "$(uname -s)" = "Darwin" ]; then
    STAT_CMD="stat -f%z "
else
    STAT_CMD="stat -c%s "
fi

# Android SDK addon file.
AAOS_SDK_ADDON_FILE=${AAOS_SDK_ADDON_FILE:-horizon-sdv-aaos-sys-img2-1.xml}
AAOS_SDK_SYSTEM_IMAGE_PREFIX=${AAOS_SDK_SYSTEM_IMAGE_PREFIX:-sdk-repo-linux-system-images}

# Cache directory
AAOS_CACHE_DIRECTORY=${AAOS_CACHE_DIRECTORY:-/aaos-cache}

# AAOS workspace and artifact storage paths
if [ -z "${WORKSPACE}" ]; then
    ORIG_WORKSPACE="${HOME}"
    WORKSPACE="${HOME}"/aaos_builds
    AAOS_CACHE_DIRECTORY="${WORKSPACE}"
    EMPTY_DIR="${HOME}"/empty_dir
else
    # Store original workspace for use later.
    ORIG_WORKSPACE="${WORKSPACE}"
    # Ensure PVC has correct privileges.
    # Note: builder Dockerfile defines USER name
    sudo chown builder:builder /"${AAOS_CACHE_DIRECTORY}"
    sudo chmod g+s /"${AAOS_CACHE_DIRECTORY}"
    WORKSPACE=/"${AAOS_CACHE_DIRECTORY}"/aaos_builds
    if [[ "${AAOS_LUNCH_TARGET}" =~ "rpi" ]]; then
        # Avoid RPI builds affecting standard android repos.
        WORKSPACE=/"${AAOS_CACHE_DIRECTORY}"/aaos_builds_rpi
    fi
    EMPTY_DIR="${AAOS_CACHE_DIRECTORY}"/empty_dir
fi

function remove_directory() {
    echo "Remove directory ${1} ..."
    mkdir -p "${EMPTY_DIR}"
    # Faster than rm -rf
    rsync -aq --delete "${EMPTY_DIR}"/ "${1}"/ || true
    # Final, remove directories.
    rm -rf "${EMPTY_DIR}"
    rm -rf "${1}"
    echo "Removed directory ${1}."
}

# Override build output directory to keep builds
# separate from each other.
export OUT_DIR="out_sdv-${AAOS_LUNCH_TARGET}"

# Clean Workspace or specific build target directory.
AAOS_CLEAN=${AAOS_CLEAN:-NO_CLEAN}
case "${AAOS_CLEAN}" in
    CLEAN_ALL)
        remove_directory "${WORKSPACE}"
        ;;
    CLEAN_BUILD)
        remove_directory "${WORKSPACE}"/"${OUT_DIR}"
        ;;
    NO_CLEAN)
        echo "Reusing existing ${WORKSPACE}..."
        ;;
    *)
        ;;
esac

function create_workspace() {
    mkdir -p "${WORKSPACE}" > /dev/null 2>&1
    cd "${WORKSPACE}" || exit
}

function recreate_workspace() {
    remove_directory "${WORKSPACE}"
    create_workspace
}

create_workspace

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
elif [[ "${AAOS_LUNCH_TARGET}" =~ "tangor" ]]; then
    AAOS_ARCH="arm64"
fi

# Declare articact array.
declare -a AAOS_ARTIFACT_LIST

# Define the make command line for given target
AAOS_MAKE_CMDLINE=""

# If Jenkins, or local, the artifacts differ so update.
USER=$(whoami)
# Post build commands
declare -a POST_BUILD_COMMANDS
# Post storage commands
declare -a POST_STORAGE_COMMANDS

# This is a dictionary mapping the target names to the command line
# to build the image.
case "${AAOS_LUNCH_TARGET}" in
    aosp_rpi*)
        AAOS_MAKE_CMDLINE="m bootimage systemimage vendorimage"
        # FIXME: we can build full flashable image but may require special
        # permissions, for now host the individual parts.
        # ${VERSION}-${DATE}-rpi5.img # rpi5-mkimg.sh
        AAOS_ARTIFACT_LIST=(
            "${OUT_DIR}/target/product/${AAOS_ARCH}/boot.img"
            "${OUT_DIR}/target/product/${AAOS_ARCH}/system.img"
            "${OUT_DIR}/target/product/${AAOS_ARCH}/vendor.img"
        )
        ;;
    sdk_car*)
        AAOS_MAKE_CMDLINE="m && m emu_img_zip && m sbom"
        AAOS_ARTIFACT_LIST=(
            "${OUT_DIR}/target/product/emulator_car64_${AAOS_ARCH}/sbom.spdx.json"
            "${OUT_DIR}/target/product/emulator_car64_${AAOS_ARCH}/${AAOS_SDK_SYSTEM_IMAGE_PREFIX}*.zip"
            "${OUT_DIR}/target/product/emulator_car64_${AAOS_ARCH}/${AAOS_SDK_ADDON_FILE}"
        )
        ;;
    aosp_cf*)
        AAOS_MAKE_CMDLINE="m dist"
        AAOS_ARTIFACT_LIST=(
            "${OUT_DIR}/dist/cvd-host_package.tar.gz"
            "${OUT_DIR}/dist/sbom/sbom.spdx.json"
            "${OUT_DIR}/dist/aosp_cf_${AAOS_ARCH}_auto-img*.zip"
        )
        # If the AAOS_BUILD_CTS variable is set, build only the cts image.
        if [[ "$AAOS_BUILD_CTS" -eq 1 ]]; then
            AAOS_MAKE_CMDLINE="m cts -j16"
            AAOS_ARTIFACT_LIST=("${OUT_DIR}/host/linux-x86/cts/android-cts.zip")
        fi
        ;;
    *tangorpro_car*)
        AAOS_MAKE_CMDLINE="m && m android.hardware.automotive.vehicle@2.0-default-service android.hardware.automotive.audiocontrol-service.example"
        AAOS_ARTIFACT_LIST=(
            "vendor.tgz"
        )
        # Pixel Tablet binaries for Android 14.0.0 (AP1A.240405.002)
        # https://developers.google.com/android/drivers#tangorproap1a.240405.002
        POST_INITIALISE_COMMANDS="curl --output - https://dl.google.com/dl/android/aosp/google_devices-tangorpro-ap1a.240405.002-8d141153.tgz | tar -xzvf - && tail -n +315 extract-google_devices-tangorpro.sh | tar -zxvf -"
        POST_BUILD_COMMANDS=(
            "cp -f ${OUT_DIR}/target/product/tangorpro/system.img vendor/google_devices/tangorpro/proprietary"
            "cp -f ${OUT_DIR}/target/product/tangorpro/bootloader.img vendor/google_devices/tangorpro/proprietary"
            "cp -f ${OUT_DIR}/target/product/tangorpro/vbmeta_vendor.img vendor/google_devices/tangorpro/proprietary"
            "cp -f ${OUT_DIR}/target/product/tangorpro/vendor.img vendor/google_devices/tangorpro/proprietary"
            "cp -f ${OUT_DIR}/target/product/tangorpro/vendor_dlkm.img vendor/google_devices/tangorpro/proprietary"
            "cp -f ${OUT_DIR}/target/product/tangorpro/android-info.txt vendor/google_devices/tangorpro/"
            "tar -czf vendor.tgz vendor"
        )
        POST_STORAGE_COMMANDS=(
            "rm -f vendor.tgz"
            "rm -rf vendor"
        )
        ;;
    *)
        # If the target is not one of the above, print an error message
        # but continue as best so people can play with builds.
        echo "WARNING: unknown target ${LUNCH_TARGET}"
        AAOS_MAKE_CMDLINE="m"
        echo "Artifacts will not be stored!"
        ;;
esac

# Additional build commands
if [ -n "${OVERRIDE_MAKE_COMMAND}" ]; then
    AAOS_MAKE_CMDLINE="${OVERRIDE_MAKE_COMMAND}"
fi
if [ -n "${ADDITIONAL_INITIALISE_COMMANDS}" ]; then
    if [ -n "${POST_INITIALISE_COMMANDS}" ]; then
        POST_INITIALISE_COMMANDS+=" && ${ADDITIONAL_INITIALISE_COMMANDS}"
    else
        POST_INITIALISE_COMMANDS+="${ADDITIONAL_INITIALISE_COMMANDS}"
    fi
fi

# Gerrit Review environment variables: remove leading and trailing slashes.
GERRIT_PROJECT=$(echo "${GERRIT_PROJECT}" | xargs)
GERRIT_CHANGE_NUMBER=$(echo "${GERRIT_CHANGE_NUMBER}" | xargs)
GERRIT_PATCHSET_NUMBER=$(echo "${GERRIT_PATCHSET_NUMBER}" | xargs)

# Define artifact storage strategy and functions.
AAOS_ARTIFACT_STORAGE_SOLUTION=${AAOS_ARTIFACT_STORAGE_SOLUTION:-"GCS_BUCKET"}
AAOS_ARTIFACT_STORAGE_SOLUTION=$(echo "${AAOS_ARTIFACT_STORAGE_SOLUTION}" | xargs)

# Artifact storage bucket
AAOS_ARTIFACT_ROOT_NAME=${AAOS_ARTIFACT_ROOT_NAME:-sdva-2108202401-aaos}
AAOS_ARTIFACT_REGION=${CLOUD_REGION:-europe-west1}

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

    ANDROID_VERSION=${ANDROID_VERSION}
    ANDROID_API_LEVEL=${ANDROID_API_LEVEL}

    POST_INITIALISE_COMMANDS=${POST_INITIALISE_COMMANDS}

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
