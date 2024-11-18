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
# Run CTS tests against Android Cuttlefish Virtual Device (CVD).
#
# Reference:
# https://source.android.com/docs/devices/cuttlefish/cts
# https://android.googlesource.com/platform/cts/+/refs/heads/master/tools/cts-tradefed/res/config
# https://source.android.com/docs/compatibility/cts/command-console-v2
#
# Include common functions and variables.
# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")"/cts_environment.sh "$0"

function cts_cleanup() {
    killall cts-tradefed > /dev/null 2>&1
}

function cts_info() {
    ./cts-tradefed version | grep "Android Compatibility Test Suite" > "${WORKSPACE}"/cts-version.txt
    ./cts-tradefed list plans > "${WORKSPACE}"/cts-plans.txt
    ./cts-tradefed list modules > "${WORKSPACE}"/cts-modules.txt
}

# Wait for timeout or tradefed completion.
function cts_wait_for_completion() {
    local -r time_max="$((CTS_TIMEOUT * 60))"
    local -r timeout="${SECONDS}"+"${time_max}"
    echo "Sleep for ${time_max} seconds and wait on PID ${1}"
    while (( "${SECONDS}" < "${timeout}" )); do
        sleep 60
        if ! ps -p "$1" > /dev/null; then
            echo "Tests completed."
            break
        fi
        echo "Still waiting on completion ..." 
    done
    echo "Tests completed or timed out."
}

function cts_run() {
    # Run specific module and test if requested, else run all.
    cts_module=""
    if [ -n "${CTS_MODULE}" ]; then
        cts_module="--module ${CTS_MODULE}"
    fi

    # Check SHARD and devices match
    # If devices less than num_instances aka shards, then reduce.
    num_instances=$(adb devices | grep -c -E '0.+device$')
    shards="${SHARD_COUNT}"
    if (( shards > num_instances )); then
        echo "SHARD_COUNT (${SHARD_COUNT}) > num_instances (${num_instances})"
        echo "Setting SHARD_COUNT to ${num_instances}"
        shards=num_instances
    else
        echo "SHARD_COUNT (${SHARD_COUNT}) = num_instances (${num_instances})"
    fi

    echo "./cts-tradefed run commandAndExit ${CTS_TESTPLAN} ${cts_module} \
        --no-enable-parameterized-modules --max-testcase-run-count 2 \
        --retry-strategy RETRY_ANY_FAILURE --reboot-at-last-retry \
        --shard-count ${shards} &"
    # WARNING: do not quote and leave on a single line to avoid strange
    #          behaviour.
    # shellcheck disable=SC2086
    ./cts-tradefed run commandAndExit ${CTS_TESTPLAN} ${cts_module} --no-enable-parameterized-modules --max-testcase-run-count 2 --retry-strategy RETRY_ANY_FAILURE --reboot-at-last-retry --shard-count "${shards}" &
    cts_wait_for_completion "$!"
}

function cts_store_results() {
    # Place in WORKSPACE for Jenkins artifact archive to store with job!
    cp -rf "${HOME}"/android-cts/results  "${WORKSPACE}"/android-cts-results
    cp -f "${HOME}"/android-cts/results/latest/invocation_summary.txt  "${WORKSPACE}"/android-cts-results
}

# Main
cd "${HOME}"/android-cts/tools || exit
cts_info
cts_run
RESULT="$?"
cts_store_results
cts_cleanup

# Return result
echo "Exit ${RESULT}"
exit "${RESULT}"
