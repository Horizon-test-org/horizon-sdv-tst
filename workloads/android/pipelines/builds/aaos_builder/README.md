# Android Build Configuration

The following provides examples of the environment variables and Jenkins build parameters in order to build Android Automotive virtual devices, and platform targets.

This supports builds for:

*  [Android Virtual Devices](https://source.android.com/docs/automotive/start/avd/android_virtual_device) for use with [Android Studio](https://source.android.com/docs/automotive/start/avd/android_virtual_device#share-an-avd-image-with-android-studio-users)
* [Cuttlefish Virtual Devices](https://source.android.com/docs/devices/cuttlefish) for use with [CTS](https://source.android.com/docs/compatibility/cts) and emulators.
* Reference hardware platforms such as [RPi](https://github.com/raspberry-vanilla/android_local_manifest) and [Pixel Tablets](https://source.android.com/docs/automotive/start/pixelxl).


# Environment Variables/Parameters

## AAOS_GERRIT_MANIFEST_URL

This provides the URL for the Android repo manifest. Such as:

* https://dev.horizon-sdv.scpmtk.com/android/platform/manifest (default)
* https://android.googlesource.com/platform/manifest

## AAOS_REVISION

The Android revision, ie branch or tag to build. Such as:

* horizon/android-14.0.0_r30 (ap1a - default)
* android14-qpr1-automotiveos-release
* android-14.0.0_r22
* android-14.0.0_r30 (ap1a)
* android-14.0.0_r74 (ap2a, refer to Known Issues)
* android-15.0.0_r4 (ap3a)
* android-15.0.0_r10 (ap4a)

## AAOS_LUNCH_TARGET

The Android target to build Android cuttlefish, virtual devices, Pixel and RPi targets.

Reference: [Codenames, tags, and build numbers](https://source.android.com/docs/setup/reference/build-numbers)

Examples:

- Virtual Devices:
    -   `sdk_car_x86_64-userdebug`
    -   `sdk_car_x86_64-ap1a-userdebug`
    -   `sdk_car_x86_64-ap2a-userdebug`
    -   `sdk_car_x86_64-ap3a-userdebug`
    -   `sdk_car_x86_64-ap4a-userdebug`
    -   `sdk_car_arm64-userdebug`
    -   `sdk_car_arm64-ap1a-userdebug`
    -   `sdk_car_arm64-ap2a-userdebug`
    -   `sdk_car_arm64-ap3a-userdebug`
    -   `sdk_car_arm64-ap4a-userdebug`
    -   `aosp_cf_x86_64_auto-userdebug`
    -   `aosp_cf_x86_64_auto-ap1a-userdebug`
    -   `aosp_cf_x86_64_auto-ap2a-userdebug`
    -   `aosp_cf_x86_64_auto-ap3a-userdebug`
    -   `aosp_cf_x86_64_auto-ap4a-userdebug`
    -   `aosp_cf_arm64_auto-userdebug`
    -   `aosp_cf_arm64_auto-ap1a-userdebug`
    -   `aosp_cf_arm64_auto-ap2a-userdebug`
    -   `aosp_cf_arm64_auto-ap3a-userdebug`
    -   `aosp_cf_arm64_auto-ap4a-userdebug`
-   Pixel Devices:
    -   `aosp_tangorpro_car-ap1a-userdebug`
    -   `aosp_tangorpro_car-ap2a-userdebug`
    -   `aosp_tangorpro_car-ap3a-userdebug`
-   Raspberry Pi:
    -   `aosp_rpi4_car-ap4a-userdebug`
    -   `aosp_rpi5_car-ap4a-userdebug`

## ANDROID_VERSION

This is required for the SDK Car AVD builds so that the correct `devices.xml` and SDK Addon can be generated for use with Android Studio.

## POST_REPO_INITIALISE_COMMAND

This allows the user to include additional commands to run after the repo has been initialised.


## POST_REPO_SYNC_COMMAND

This allows the user to include additional commands to run after the repo has been synced.

## OVERRIDE_MAKE_COMMAND

This allows the user to override the default target make command.

## AAOS_RPI_REVISION

See  [RPi](https://github.com/raspberry-vanilla/android_local_manifest), define the tag/branch to use. This must align with `AAOS_REVISION`.

## AAOS_CLEAN

Option to clean the build workspaace, either fully or simply for the `AAOS_LUNCH_TARGET` target defined.

## GERRIT_REPO_SYNC_JOBS

This is the value used for parallel jobs for `repo sync`, ie `-j <GERRIT_REPO_SYNC_JOBS>`.
The default is defined in system environment variable: `REPO_SYNC_JOBS`.
The minimum is 1 and the maximum is 24.

## INSTANCE_RETENTION_TIME

Keep the build VM instance and container running to allow user to connect to it. Useful for debugging build issues, determining target output archives etc.

Access using `kubectl` e.g. `kubectl exec -it -n jenkins <pod name> -- bash` from `bastion` host.

## AAOS_ARTIFACT_STORAGE_SOLUTION

Define storage solution used to push artifacts.

Currently `GCS_BUCKET` default pushes to GCS bucket, if empty then nothing will be stored.

## GERRIT_PROJECT / GERRIT_CHANGE_NUMBER / GERRIT_PATCHSET_NUMBER

These allow the user to fetch a specific Gerrit patchset.

# KNOWN ISSUES

## `android-qpr1-automotiveos-release` and Cuttlefish Virtual Devices:

-   Avoid using for Cuttlefish Virtual Devices. Use `android-14.0.0_r30` instead.
    -   Black Screen, unresponsive, sluggish UI issues.

## `android-14.0.0_r30` and `tangorpro_car-ap1a`:

-   Fix the audio crash:

    -   Take a patch (https://android-review.googlesource.com/c/platform/packages/services/Car/+/3037383):
        -  Build with the following parameters:
	    - `GERRIT_PROJECT=platform/packages/services/Car`
	    - `GERRIT_CHANGE_NUMBER=3037383`
	    - `GERRIT_PATCHSET_NUMBER=2`
    -   Reference: [Pixel Tablets](https://source.android.com/docs/automotive/start/pixelxl)

## `android-14.0.0_r74` and some earlier releases:

-   To avoid DEX build issues for AAOSP builds on standalone build instances:

    -   Build with `WITH_DEXPREOPT=false`, eg. `m WITH_DEXPREOPT=false`

-   Avoid surround view automotive test issues breaking builds:

    -   i.e. Unknown installed file for module 'sv_2d_session_tests'/'sv_3d_session_tests'

    -   Either [Revert](https://android.googlesource.com/platform/platform_testing/+/b608b75b5f2a5f614bd75599023a45f3c321d4a9 "https://android.googlesource.com/platform/platform_testing/+/b608b75b5f2a5f614bd75599023a45f3c321d4a9") commit, or download the revert change from Gerrit review:
	    - `GERRIT_PROJECT=platform/platform_testing`
	    - `GERRIT_CHANGE_NUMBER=3183939`
	    - `GERRIT_PATCHSET_NUMBER=1`

	  or locally remove erroneous tests from native_test_list.mk:
	   -   `sed -i '/sv_2d_session_tests/,/sv_3d_session_tests/d' build/tasks/tests/native_test_list.mk`
       -   `sed -i 's/evsmanagerd_test \\/evsmanagerd_test/' build/tasks/tests/native_test_list.mk`

## `android-15.0.0_r10` and Cuttlefish Virtual Devices

-   Avoid multiple instances when running Cuttlefish. Instance 1 works fine, instance 2 and onwards do not work.
    -   `android-15.0.0_r4` is a more reliable release.

-   CTS (full) does not complete in timely manner:
    -   `android-15.0.0_r4`  : 43m29s
    -   `android-15.0.0_r10` : 3h and not completed (stuck in `CtsLibcoreOjTestCases` tests).
    -   `android-15.0.0_r10` : very new, latest and thus expect bugs.

## CTS

-   If using later releases than `android-14.0.0_r30`, consider tailoring the CTS Execution resources to suit those of
    the version under test. The number of instances, CPUs and Memory defaults are set up as default for `android-14.0.0_r30`.

## Vanilla RPi

- Pay attention to [RPi](https://github.com/raspberry-vanilla/android_local_manifest). We can't support a moving target, we try but RPi is unsupported, work with Google or fork if required!
