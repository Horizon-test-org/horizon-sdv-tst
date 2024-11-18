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
# Build AAOS targets.
#
# This script will build the AAOS image(s) for the given target. The
# target is determined by the AAOS_LUNCH_TARGET environment variable.
#
# The build command line is determined by a case statement based on the
# value of AAOS_LUNCH_TARGET. If AAOS_LUNCH_TARGET is not one of the
# supported values, the script will exit with an error message.
#
# Supported AAOS_LUNCH_TARGET are:
#   - aosp_rpi4_car-userdebug
#   - aosp_rpi5_car-userdebug
#   - sdk_car_arm64-userdebug
#   - sdk_car_x86_64-userdebug
#   - aosp_cf_arm64_auto-userdebug
#   - aosp_cf_x86_64_auto-userdebug

# Include common functions and variables.
# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")"/aaos_environment.sh "$0"

if [ -n "${AAOS_MAKE_CMDLINE}" ]; then
    # Set environment variables and build target
    # shellcheck disable=SC1091
    source build/envsetup.sh
    lunch "${AAOS_LUNCH_TARGET}"

    echo "Building: $AAOS_MAKE_CMDLINE"

    # Run the build.
    eval "${AAOS_MAKE_CMDLINE}"
else
    echo "Error: make command line undefined!"
    exit 255
fi

# Return result
exit $?
