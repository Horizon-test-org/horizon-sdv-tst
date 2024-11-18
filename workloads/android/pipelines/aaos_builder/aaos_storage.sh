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
# Store AAOS targets to artifact area.
#
# This script will store the specified AAOS target to the artifact area.
# The target is determined by the AAOS_LUNCH_TARGET environment variable.
#
# Supported AAOS_LUNCH_TARGET are:
#   - aosp_rpi4_car-userdebug
#   - aosp_rpi5_car-userdebug
#   - sdk_car_arm64-userdebug
#   - sdk_car_x86_64-userdebug
#   - aosp_cf_arm64_auto-userdebug
#   - aosp_cf_x86_64_auto-userdebug
#

# Include common functions and variables.
# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")"/aaos_environment.sh "$0"

#
# Store artifacts to GCS Bucket storage.
#
# This function stores the artifacts to GCS Bucket storage.
# It takes no arguments and prints a message to indicate that the
# artifacts are being stored to the bucket.
#
# The artifacts are copied to the bucket using the gsutil command.
# The destination is determined by the AAOS_ARTIFACT_ROOT_NAME and
# the job name and build number.
#
# If the bucket does not exist, it is created.
# shellcheck disable=SC2317
function gcs_bucket() {
    local -r bucket_name="gs://${AAOS_ARTIFACT_ROOT_NAME}"
    # Replace spaces in Jenkins Job Name
    BUCKET_FOLDER="${JOB_NAME// /_}"
    local -r destination="${bucket_name}/${BUCKET_FOLDER}/${AAOS_BUILD_NUMBER}/"
    local -r cloud_url="https://storage.cloud.google.com"

    # Check if the bucket exists
    # If not, create it
    if ! /usr/bin/gsutil ls -b "${bucket_name}"
    then
        echo "Creating bucket ${bucket_name}"
        /usr/bin/gsutil mb -l "${AAOS_ARTIFACT_REGION}" "${bucket_name}"
    fi

    # Copy artifacts to Google Cloud Storage bucket
    echo "Storing artifacts to bucket ${bucket_name}"
    for artifact in "${AAOS_ARTIFACT_LIST[@]}"; do
        # Copy the artifact to the bucket
        /usr/bin/gsutil cp "${artifact}" "${destination}"
        echo "Copied ${artifact} to ${destination}"
    done

    # Print HTTP download URL links in console log.
    echo "Artifacts for ${JOB_NAME}/${AAOS_BUILD_NUMBER} stored in ${destination}"
    echo "Bucket URL: ${cloud_url}/${AAOS_ARTIFACT_ROOT_NAME}"

    for artifact in "${AAOS_ARTIFACT_LIST[@]}"; do
        # shellcheck disable=SC2086
        echo "Artifact URL: ${destination}/$(echo ${artifact} | awk -F / '{print $NF}')"
    done
}

#
# A noop function that does nothing.
#
# This function is used when the AAOS_ARTIFACT_STORAGE_SOLUTION is not
# supported. It prints a message to indicate that the artifacts are not
# being stored to any storage solution.
# shellcheck disable=SC2317
function noop() {
    echo "Noop: skipping artifact stored to ${AAOS_ARTIFACT_STORAGE_SOLUTION}" >&2
    for artifact in "${AAOS_ARTIFACT_LIST[@]}"; do
        echo "Skipping copy of ${artifact}" >&2
    done
}

#
# Storage selection.
#
# This case statement sets the AAOS_ARTIFACT_STORAGE_SOLUTION_FUNCTION
# variable to the appropriate function to call to store artifacts to
# the given storage solution.
case "${AAOS_ARTIFACT_STORAGE_SOLUTION}" in
    GCS_BUCKET)
        AAOS_ARTIFACT_STORAGE_SOLUTION_FUNCTION=gcs_bucket
        ;;
    *)
        AAOS_ARTIFACT_STORAGE_SOLUTION_FUNCTION=noop
        ;;
esac

# Store artifacts to artifact storage.
if [ -n "${AAOS_ARTIFACT_STORAGE_SOLUTION}" ] && [ -n "${AAOS_BUILD_NUMBER}" ]; then
    "${AAOS_ARTIFACT_STORAGE_SOLUTION_FUNCTION}"
else
    # If not running from Jenkins, just NOOP!
    noop
fi

# Return result
exit $?
