# CVD Launcher Pipeline

## Table of contents
- [Introduction](#introduction)
- [Environment Variables/Parameters](#environment-variables)
- [System Variables](#system-variables)

## Introduction <a name="introduction"></a>

This pipeline is run on GCE Cuttlefish VM instances from the instance templates that were previously created by the environment pipeline. It allows users to test their Cuttlefish virtual device (CVD) image builds.

The pipeline first runs CVD on the Cuttlefish VM Instance to instantiate the specified number of devices and then connects to MTK Connect so that users can test their builds (UI and adb).

### References <a name="references"></a>

- [Cuttlefish Virtual Devices](https://source.android.com/docs/devices/cuttlefish)
- [Android Cuttlefish](https://github.com/google/android-cuttlefish)

## Environment Variables/Parameters <a name="environment-variables"></a>

### JENKINS\_GCE\_CLOUD\_LABEL

This is the label that identifies the GCE Cloud label which will be used to identify the Cuttlefish VM instance, e.g.

- `cuttlefish-vm-main`
- `cuttlefish-vm-v110`

Note: The value provided must correspond to a cloud instance or the job will hang. 

### CUTTLEFISH\_DOWNLOAD\_URL

This is the Cuttlefish Virtual Device image that is to be tested. It is built from `AAOS Builder` for the `aosp_cf` build targets.

The URL must point to the bucket where the host packages and virtual devices images archives are stored:

- `cvd-host_package.tar.gz`
- `osp_cf_x86_64_auto-img-builder.zip`

URL is of the form `gs://<ANDROID_BUILD_BUCKET_ROOT_NAME>/Android/Builds/AAOS_Builder/<BUILD_NUMBER>` where `ANDROID_BUILD_BUCKET_ROOT_NAME` is a system environment variable defined in Jenkins CasC `jenkins.yaml` and `BUILD_NUMBER` is the Jenkins build number.

### CUTTLEFISH\_MAX\_BOOT\_TIME

Cuttlefish virtual devices need time to boot up. This defines the maximum time to wait for the virtual device to boot up.

Time is in seconds.

### CUTTLEFISH\_KEEP\_ALIVE\_TIME

If wishing to test using MTK Connect, Cuttlefish VM instance must be allowed to continue to run. This timeout, in
minutes, gives the tester time to keep the instance alive so they may work with the devices via MTK Connect.

### NUM\_INSTANCES

Defines the number of Cuttlefish virtual devices to launch.

This applies to CVD `num-instances` parameters.

### VM\_CPUS

Defines the number of CPU cores to allocate to the Cuttlefish virtual device.

This applies to CVD `cpus` parameter.

### VM\_MEMORY\_MB

Defines total memory available to guest.

This applies to CVD `memory_mb` parameter.

## SYSTEM VARIABLES <a name="system-variables"></a>

There are a number of system environment variables that are unique to each platform but required by Jenkins build, test and environment pipelines.

These are defined in Jenkins CasC `jenkins.yaml` and can be viewed in Jenkins UI under `Manage Jenkins` -> `System` -> `Global Properties` -> `Environment variables`.

These are as follows:

-   `ANDROID_BUILD_BUCKET_ROOT_NAME`
     - Defines the name of the Google Storage bucket that will be used to store build and test artifacts

-   `ANDROID_BUILD_DOCKER_ARTIFACT_PATH_NAME`
    - Defines the registry path where the Docker image used by builds, tests and environments is stored.

-   `CLOUD_PROJECT`
    - The GCP project, unique to each project. Important for bucket, registry paths used in pipelines.

-   `CLOUD_REGION`
    - The GCP project region. Important for bucket, registry paths used in pipelines.

-   `CLOUD_ZONE`
    - The GCP project zone. Important for bucket, registry paths used in pipelines.

-   `HORIZON_DOMAIN`
    - The URL domain which is required by pipeline jobs to derive URL for tools and GCP.

-   `JENKINS_SERVICE_ACCOUNT`
    - Service account to use for pipelines. Required to ensure correct roles and permissions for GCP resources.
