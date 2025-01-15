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
# Start(Launch) and Stop Cuttlefish Virtual Device (CVD) host.
#
# References:
# * https://github.com/google/android-cuttlefish
# * https://source.android.com/docs/devices/cuttlefish/multi-tenancy
# * https://source.android.com/docs/devices/cuttlefish/get-started
#
# Notes:
# Cuttlefish multi-tenancy allows for your host machine to launch multiple
# virtual guest devices with a single launch invocation. TCP sockets start
# at port 6520 and increment. The cuttlefish-base debian package, preallocates
# resources for 10 instances.
#
# Script be run locally, eg.
#   cvd_start_stop.sh
#
# Include common functions and variables.
# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")"/cvd_environment.sh "$0"

declare BOOTED_INSTANCES=0

# CVD log file.
WORKSPACE="${WORKSPACE:-.}"
declare -r logfile="${WORKSPACE}"/cvd-"${BUILD_NUMBER}".log

# Download CVD host package and Cuttlefish AVD artifacts
function cuttlefish_extract_artifacts() {
    mkdir -p "${HOME}"/cf
    cd "${HOME}"/cf || exit

    case "${CUTTLEFISH_DOWNLOAD_URL}" in
        gs://*)
            gsutil cp "${CUTTLEFISH_DOWNLOAD_URL}"/cvd-host_package.tar.gz .
            gsutil cp "${CUTTLEFISH_DOWNLOAD_URL}"/aosp_cf_"${ARCHITECTURE}"_auto-img*.zip .
            ;;
        *)
            wget -nv "${CUTTLEFISH_DOWNLOAD_URL}"/cvd-host_package.tar.gz .
            wget -r -nd -nv --no-parent -A "aosp_cf_${ARCHITECTURE}_auto-img*.zip" "${CUTTLEFISH_DOWNLOAD_URL}"/
            ;;
    esac

    # Unpack the host packages.
    if ! tar -xvf cvd-host_package.tar.gz
    then
        echo "Failed to extract cvd-host_package.tar.gz"
        exit 1
    fi

    # Unpack the Cuttlefish device images.
    if ! unzip aosp_cf_"${ARCHITECTURE}"_auto-img*.zip
    then
        echo "Failed to extract aosp_cf_${ARCHITECTURE}_auto-img*.zip"
        exit 1
    fi

    # Clean up
    rm -f aosp_cf_"${ARCHITECTURE}"_auto-img*.zip
    rm -f cvd-host_package.tar.gz
}

# Start Cuttlefish Virtual Device (CVD) host.
function cuttlefish_start() {

    cd "${HOME}"/cf || exit

    # Remove log file.
    rm -f "${logfile}"

    # Options:
    # resume: do not resume using the disk from the last session.
    # config: default to auto
    # report_anonymous_usage_stats: default to no, avoids user input.
    # num_instances: number of guest instances to launch.
    # cpus: virtual CPU count.
    # memory_mb: total memory available to guest.
    HOME="${PWD}" ./bin/launch_cvd --resume=false --config=auto \
      -report_anonymous_usage_stats=no \
      --num-instances="${NUM_INSTANCES}" --cpus "${VM_CPUS}" \
      --memory_mb "${VM_MEMORY_MB}" > "${logfile}" 2>&1 &
}

# Wait for device to boot (VIRTUAL_DEVICE_BOOT_COMPLETED) or timeout.
function cuttlefish_wait_for_device_booted() {
    local -r timeout="${SECONDS}"+"${CUTTLEFISH_MAX_BOOT_TIME}"
    while (( "${SECONDS}" < "${timeout}" )); do
        sleep 4
        BOOTED_INSTANCES=$(grep -c VIRTUAL_DEVICE_BOOT_COMPLETED "${logfile}")
        if (( BOOTED_INSTANCES == NUM_INSTANCES )); then
            break
        fi
    done
}

# Wait for timeout, leaving CVD session in place.
function cuttlefish_keep_alive() {
    local -r alive_time_max="$((CUTTLEFISH_KEEP_ALIVE_TIME * 60))"
    local -r timeout="${SECONDS}"+"${alive_time_max}"
    echo "Sleep for ${alive_time_max} seconds" | tee -a "${logfile}"
    while (( "${SECONDS}" < "${timeout}" )); do
        sleep 60
        echo "Still alive ..." | tee -a "${logfile}"
        adb devices | tee -a "${logfile}"
    done
    echo "Ready to terminate!"
}

# Ensure CVD is terminated.
function cuttlefish_cleanup() {
    cd "${HOME}" || exit
    killall run_cvd launch_cvd > /dev/null 2>&1
    rm -rf "${HOME}"/cf > /dev/null 2>&1
}

# Stop CVD.
function cuttlefish_stop() {
    cd "${HOME}"/cf || exit
    adb reboot
    HOME="${HOME}/cf" ./bin/stop_cvd
}

# Archive logs
function cuttlefish_archive_logs() {
    cd "${HOME}"/cf/cuttlefish_runtime.1/ || true
    tar -czf "${WORKSPACE}"/cuttlefish_logs-"${BUILD_NUMBER}".tgz logs || true
}

case "${1}" in
    --stop)
        # Stop
        cuttlefish_archive_logs
        cuttlefish_stop
        cuttlefish_cleanup
        ;;
    --keep-alive)
        # Keep CVD session alive
        cuttlefish_keep_alive
        ;;
    --start|*)
        # Start
        cuttlefish_cleanup
        cuttlefish_extract_artifacts
        cuttlefish_start
        cuttlefish_wait_for_device_booted
        if (( BOOTED_INSTANCES > 0 )); then
            echo "Boot successful:"
            echo "    Booted ${BOOTED_INSTANCES} instances of ${NUM_INSTANCES}"
            # Allow system time to settle.
            echo "    Sleep 90 seconds"
			# Ensure adb devices show devices.
            sudo adb kill-server || true
            sleep 30
            sudo adb start-server || true
            sleep 60
            adb devices
        else
            echo "Device(s) not booted within ${CUTTLEFISH_MAX_BOOT_TIME} seconds"
            # Stop and clean up
            cuttlefish_archive_logs
            cuttlefish_stop
            cuttlefish_cleanup
            sudo reboot
            exit 1
        fi
        ;;
esac
