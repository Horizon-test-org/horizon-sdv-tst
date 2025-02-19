# Cuttlefish Instance Template Pipeline

## Table of contents
- [Introduction](#introduction)
- [Environment Variables/Parameters](#environment-variables)
- [System Variables](#system-variables)

## Introduction <a name="introduction"></a>

This pipeline is used to create the Cuttlefish instance templates that will be used by Jenkins tests pipelines to launch CVD and run CTS tests. The pipeline may not be run concurrently this is to avoid clashes with temporary artifacts the job creates in order to produce the Cuttlefish instance template.

The instance templates are referenced within Jenkins CasC `jenkins.yaml` `computeEngine` entries. These can be viewed in Jenkins UI under `Manage Jenkins` -> `Clouds`.

### References <a name="references"></a>

- [Cuttlefish Virtual Devices](https://source.android.com/docs/devices/cuttlefish) for use with [CTS](https://source.android.com/docs/compatibility/cts) and emulators.
- [Virtual Device for Android host-side utilities](https://github.com/google/android-cuttlefish)
- [Compatibility Test Suite downloads](https://source.android.com/docs/compatibility/cts/downloads)
- [Compute Instance Templates](https://cloud.google.com/sdk/gcloud/reference/compute/instance-templates/create)

## Environment Variables/Parameters <a name="environment-variables"></a>

### ANDROID_CUTTLEFISH_REVISION

This defines the version of Android Cuttlefish host packages to use, e.g.

- `main` - the main working branch of `android-cuttlefish`
- `v1.1.0` - the latest tagged version.

This will result in an instance template of the form `instance-template-cuttlefish-vm-main-debian` or `instance-template-cuttlefish-vm-v110-debian`.

User may define any valid version so long as it supports `tools/buildutils/build_packages.sh` because the scripts are dependent on that build script.

### MACHINE_TYPE

The machine type they wish to use for the VM instance, default is `n1-standard-64`.

### BOOT_DISK_SIZE

A boot disk is required to create the instance, therefore define the size of disk required.

### MAX_RUN_DURATION

VM instances are expensive, as such it is advisable to define the maximum amount of time to run the instance template before it will automatically be terminated. Avoids leaving expensive instances in running state and consuming resources.

### DEBIAN_OS_VERSION

Override the OS version. These become deprecated and superceded, hence option to update to newer version.

Keep an eye out in the console logs for `deprecated` and update as required.

### NODEJS_VERSION

MTK Connect requires NodeJS and as such this option allows you to update the version to install on the instance template.

### UNIQUE_NAME

Optional parameter to allow users to create their own unique instance templates for their own usage in development, testing.

If left empty the name will automatically derived from `ANDROID_CUTTLEFISH_REVISION`.

If user defines a unique name, ensure the following is met:

- The name should start with `cuttlefish-vm`
  - Jenkins CasC must be updated to provide a new `computeEngine` entry for this unique template.
  - Choose a sensible label, such as `cuttlefish-vm-unique-name`
  - This new cloud will appear in `Manage Jenkins` -> `Clouds`
  - Tests jobs may then reference that unique instance through `JENKINS_GCE_CLOUD_LABEL` parameter to the new cloud label.

**Note:** Must be a match of regex `(?:[a-z](?:[-a-z0-9]{0,61}[a-z0-9])?)`, i.e lower case.

### DELETE

Allows deletion of old redundant instance templates.

If user is deleting standard instances, simply define the version in `ANDROID_CUTTLEFISH_REVISION` and the instances
names will be derived automatically.

If user is deleting a uniquely created instance, i.e. one created with `UNIQUE_NAME` defined, then define the `UNIQUE_NAME`

## SYSTEM VARIABLES <a name="system-variables"></a>

There are a number of system environment variables that are unique to each platform but required by Jenkins build, test and environment pipelines.

These are defined in Jenkins CasC `jenkins.yaml` and can be viewed in Jenkins UI under `Manage Jenkins` -> `System` -> `Global Properties` -> `Environment variables`.

These are as follows:

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
