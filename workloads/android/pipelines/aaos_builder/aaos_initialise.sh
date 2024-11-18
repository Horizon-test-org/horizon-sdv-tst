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
# Initialise the AAOSP repositories.
#
# This script does the following:
#
#  1. Initialises the repository checkout using the given manifest.
#  2. Adds the RPi manifest if the target is an RPi device.
#  3. Downloads the given changeset if the build is from an open review.
#
# The following variables must be set before running this script:
#
#  - AAOS_GERRIT_MANIFEST_URL: the URL of the AAOS manifest.
#  - AAOS_REVISION: the branch or version of the AAOS manifest.
#  - AAOS_LUNCH_TARGET: the target device.
#
# Optional variables:
#  - AAOS_CLEAN_BUILD: whether to clean the build directory before building.
#  - AAOS_ARTIFACT_STORAGE: the persistent storage location for artifacts
#
# For Gerrit review change sets:
#  - GERRIT_PROJECT: the name of the project to download.
#  - GERRIT_CHANGE_NUMBER: the change number of the changeset to download.
#  - GERRIT_PATCHSET_NUMBER: the patchset number of the changeset to download.

# Include common functions and variables.
# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")"/aaos_environment.sh "$0"

# Initialise repo checkout.
repo init -u "${AAOS_GERRIT_MANIFEST_URL}" -b "${AAOS_REVISION}" --depth=1

# Add RPi manifests if needed.
if [[ "${AAOS_LUNCH_TARGET}" =~ "rpi" ]]; then
    # Download the RPi manifest if we are building for an RPi device.
    curl -o .repo/local_manifests/manifest_brcm_rpi.xml \
        -L "${AAOS_GERRIT_RPI_MANIFEST_URL}/${AAOS_RPI_REVISION}/manifest_brcm_rpi.xml" \
        --create-dirs || exit 255
    curl -o .repo/local_manifests/remove_projects.xml \
        -L "${AAOS_GERRIT_RPI_MANIFEST_URL}/${AAOS_RPI_REVISION}/remove_projects.xml" \
        || exit 255
else
    # Remove any old RPi manifests
    rm .repo/local_manifests/manifest_brcm_rpi.xml > /dev/null 2>&1
    rm .repo/local_manifests/remove_projects.xml > /dev/null 2>&1
fi

# Clean previous changes.
# This will automatically clean any previous downloaded changes.
# -j1 because that's what fail-fast recommends otherwise 1st sync will
# take an eternity to fail..
if ! repo sync -l --force-sync --fail-fast -j 1
then
    # 1st sync failed, so perform a full sync.
    echo "ERROR: repo sync failed, performing a full sync"
    if ! repo sync --no-clone-bundle --fail-fast --force-sync -j 2
    then
        echo "ERROR: repo sync failed"
        exit 255
    fi
fi

echo "SUCCESS: repo sync complete."

# Download changeset if building from a Gerrit open review.
if [[ -n "${GERRIT_PROJECT}" && -n "${GERRIT_CHANGE_NUMBER}" && -n "${GERRIT_PATCHSET_NUMBER}" ]]; then
    # Download the given changeset if the build is from an open review.
    REPO_CMD="repo download $GERRIT_PROJECT $GERRIT_CHANGE_NUMBER/$GERRIT_PATCHSET_NUMBER"
    echo "$REPO_CMD"
    eval "${REPO_CMD}"
fi

# Return result
exit $?
