# ACN Horizon SDV

## Overview   
ACN Horizon SDV is designed to simplify the deployment and management of Android workloads on Google Kubernetes Engine clusters. By leveraging Infrastructure as Code (IaC) and GitOps, ensuring the cluster consistently matches the desired state, enabling scalable and efficient Android workload operations.

## Table of Contents
- [Overview](#overview)
- [Technologies](#technologies)
- [Project directories and files](#project-directories-and-files)
- [Exercise #1 - Prerequsites](#exercise-1---prerequsites)
- [Exercise #2 - Setup and Usage (WIP)](#exercise-2---setup-and-usage-wip)
   - [Exercise #2a - GCP Project details](#exercise-2a---gcp-project-details)
   - [Exercise #2b - Create a Bucket in GCP](#exercise-2b---create-a-bucket-in-gcp)
   - [Exercise #2c - Setting up GCP IAM and Admin for Terraform Workflow](#exercise-2c---setting-up-gcp-iam-and-admin-for-terraform-workflow)
   - [Exercise #2d - Create OAuth2 client and secret](#exercise-2d---create-oauth2-client-and-secret)
   - [Exercise #2e - Create GitHub Organization and Repository](#exercise-2e---create-github-organization-and-repository)
   - [Exercise #2f - Create GitHub Application](#exercise-2f---create-github-application)
   - [Exercise #2g - Fork the repository](#exercise-2g---fork-the-repository)
   - [Exercise #2h - Set up GitHub Environment](#exercise-2h---set-up-github-environment)
- [Exercise #3 - Verification](#exercise-3---verification)
   - [Exercise #3a - Running test builds](#exercise-3a---running-test-builds)
- [Exercise #4 - Troubleshooting](#exercise-4---troubleshooting)

## Technologies   
Technologies being used to provision the infrastructure along with the required applications for the GKE cluster.
* Google Cloud Platform - Cloud service provider for infrastructure provisioning.
* Terraform - IaC tool used to provision the infrastructure to maintain infrastructure consistency.
* Github - Source code management tool where infrastructure configuration, Kubernetes application manifests, workflows etc are stored.
* Github Actions - Continuous Integration (CI) platform used for automating the deployment process.
* Argo CD - Used to deploy Kubernetes application to match the desired state as in the GitHub repository configuration files.

## Project directories and files
The project is implemented in the following directories:

+ **.github/workflows** - Consists of GitHub Action workflows directing the operation of the CI build.
+ **gitops** - Kubernetes application manifests which will be used by Argo CD to deploy applications.
+ **terraform** - IaC configuration files to provision the infrastructure required for the GKE cluster.
+ **workloads** - Jenkins workflow scripts for the pipeline build jobs.

## Exercise #1 - Prerequsites
### General
* If you do not prefer using the Cloud Shell on GCP Console, install GCP CLI tools like `gcloud`, `gsutil` and `bq` locally. (Install instructions [here](https://cloud.google.com/sdk/docs/install)).
* Admin script to be executed.
* Pixel Tablet firmware installation is ready.

### GitHub
* Each team-member has GitHub account.
* Access to AGBG organization and Hackathon repository.
* Fork this repository to private GitHub area.

### Google Cloud Platform
* Configured GCP account / project.
* Each team-member able to update configuration in settings such as Secrets and Variables to customize it to use by the team.
* Google cloud project with the below APIs enabled:
   - IAM Service Account Credentials API
   - Kubernetes Engine API
   - Compute Engine API v1
   - Cloud Filestore API
   - Artifact Registry API
   - Cloud Storage API
* IAM Roles to be granted to the user or service accounts running Terraform scripts:
   - Compute Admin
   - Kubernetes Engine Admin
   - Artifact Registry Administrator
   - Cloud Filestore Editor
   - Storage Admin

### Terraform
* Access to edit the Terraform environment configuration files.
* IaC configuration files stored in GitHub repo.
* Infrastructure provisioned via CLI or GitHub Actions.

## Exercise #2 - Setup and Usage (WIP)
This section covers the steps to be followed for successfully provisioning the infrastructure along with other required tools and its configuration.  
Before getting started, make sure to fork this repository under your GitHub profile.

### Exercise #2a - GCP Project details
It is required to perform the checks mentioned in this section as this information will be required for the later sections of the setup process.
1. Default Google Compute Engine (GCE) Service Account:
   * On the console, click on IAM & Admin then, click on Service Accounts and confirm a Service Account for the GCE service is present.   
     <img src="docs/images/GCE_SA.png" width="500" />
2. Project ID:
   * On the console, click on IAM & Admin, click on Manage Resources and find the project details under the column **Name** and **ID** as below:   
     <img src="docs/images/GCP_project_id.png" width="500" />
   * It should look like: Name=`prj-s-agbg-gcp-sdv-sbx`, ID=`sdvc-2108202401`

### Exercise #2b - Create a Bucket in GCP
In the current GCP project, it is required to create a GCP Bucket to store data related to the infrastructure. Follow the below steps to create a Bucket.
1. On the GCP Console, navigate to Cloud Storage and click on Buckets.
2. Click on CREATE/CREATE BUCKET button.
3. Enter a globally unique name for the bucket. (Example: `prj-sbx-horizon-sdv-tf`)
4. Click on CREATE with default bucket configurations.

### Exercise #2c - Setting up GCP IAM and Admin for Terraform Workflow
The first step for successfully running the GitHub Actions workflow is to set the required Identity and Access Management (IAM) resources on GCP for Terraform to be able to provision the infrastructure.   

Below are the resources which are required to be configured:   
1. Workload Identity Federation Pool and Provider
2. Service Account and binding it to the Workload Identity Federation.
3. GitHub Secrets to be used by the Workflow.   
    
Lets get started, sign-in to your GCP Console and select the relevant project which you want to work on. Navigate to  IAM and Admin and follow the below mentioned steps.

#### Creating a Workload Identity Federation pool and provider
1. Under IAM and Admin, select Workload Identity Federation.
2. Click on CREATE POOL and provide all the necesarry details
   - Enter Name as "github" and Provider ID as "github-provider".
   - Select OIDC as the provider.
   - Set the issuer to URL provided by GitHub (`https://token.actions.githubusercontent.com`) for GitHub Actions. [Click here for more information](https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/configuring-openid-connect-in-google-cloud-platform#adding-a-google-cloud-workload-identity-provider)
   - Configure Provider attributes as below:    
      * "google.subject" = "assertion.sub" and click on ADD MAPPING
      * "attribute.actor" = "assertion.actor" and click on ADD MAPPING
      * "attribute.aud" = "assertion.aud" and click on ADD MAPPING
      * "attribute.repository_owner" = "assertion.repository_owner" and click on ADD MAPPING
      * "attribute.repository" = "assertion.repository" and click on ADD MAPPING
   - Configure Attribute Conditions
      * Condition CEL = "assertion.repository_owner=='GH_ORGANIZATION_NAME'"
   - Note down the Audience URL (shown just below Default audience) as below:
      * example: `"https://iam.googleapis.com/projects/966518152012/locations/global/workloadIdentityPools/github/providers/github-provider"`
   - Click save.
3. Workload Identity Federation Pool and Provider has now been created successfully.   
   <img src="docs/images/workload_identity_pool.png" width="650" />

#### Creating a Service Account
1. Under IAM and Admin, navigate to Service Accounts and click on CREATE SERVICE ACCOUNT
2. Provide `github-sa` as the name for the Service Account.
3. Now, add Owner Role to the Service Account.
4. Click on save, your Service Account has now been created successfully.

#### Binding Service Account to the Workload Identity Provider
1. To bind this Service Account to the Workload Identity Provider, Navigate to the the Workload Identity Pool created earlier.
2. Click on GRANT ACCESS and select **Grant access using Service Account impersonation**.
3. Select `github-sa` as the Service Account.
4. Select principal attribute name as `repository_owner` and attribute value as `ORGANIZATION_NAME` and click on SAVE.
5. In the next window, select Provider as `github-provider` from the drop-down menu set OIDC ID token path as `https://token.actions.githubusercontent.com`.
6. Download the config file.
7. Confirm the Service account has been bound successfully under CONNECTED SERVICE ACCOUNTS tab.   
   <img src="docs/images/workload_identity_pool_sa_bound.png" width="650" />

### Exercise #2d - Create OAuth2 client and secret
It is required to setup OAuth consent screen before creating the OAuth client and secret. Navigate to APIs & Services and follow the below mentioned steps

#### Setting up OAuth consent screen
Once in APIs & Services, click on OAuth consent screen to start the setup process.

1. Select User Type as "External" and click on CREATE.
2. Enter App name as "Horizon -SDV on GCP"
3. Provide a User support email.
4. Under App domain, provide a Application homepage link. For example, `https://sbx.horizon-sdv.scpmtk.com`.
5. Under Authorized domain, click on ADD DOMAIN and enter a relevant domain. For example, `scpmtk.com`
6. Provide email addresses under Developer contact information and click on SAVE AND CONTINUE.
7. On the next page, click on SAVE AND CONTINUE with default configurations.
8. In the Test users section, click on ADD USERS and add email addresses of users for enabling access and click on SAVE AND CONTINUE.
9. Review the Summary and click on BACK TO DASHBOARD.   
   <img src="docs/images/oauth_consent_screen.png" width="450" />   

#### Create OAuth client ID
1. Under APIs & Services, click on Credentials.
2. Click on CREATE CREDENTIALS and select "OAuth client ID" from the drop-down list.
3. Select Application type as "Web application".
4. Provide Name as "Horizon".
5. Under Authorized redirect URIs enter the URI which points google endpoint of Keycloak. Example: `https://sbx.horizon-sdv.scpmtk.com/auth/realms/horizon/broker/google/endpoint`.
6. Clicking on CREATE opens a pop-up window containing client ID and secret which can be copied and saved locally to a file or download the credential detail as a JSON file. (Below credentials are no longer active)   
   <img src="docs/images/oauth_client_details.png" width="350" />
7. The credential will appear Under OAuth 2.0 Client IDs as below and credential details can be viewed and edited by clicking on the Name of the OAuth 2.0 Client ID.   
   <img src="docs/images/oauth2_list.png" width="490" />

### Exercise #2e - Create GitHub Organization and Repository
In this section, steps for creating a GitHub organization or repository. Before we get started on creating a GitHub organization, it is required to have a GitHub account. If you do not have a Github account already, sign up [here](https://docs.github.com/en/get-started/start-your-journey/creating-an-account-on-github).

#### Create a GitHub Organization
1. Log in to GitHub, click on your profile (top-right corner of the page) and select "Your organizations".
2. Click on "New Organization" under Organizations. (Do not click on the option to turn your account into an organization under **Transform account**, changes may not be reversible)
3. Click on "Create a free organization".
4. Enter Organization name of your choice.
5. Enter your email address as the Contact email.
6. Set organization belonging to "My personal account".
7. Accept the terms of service and click on Next.
8. In the next step, you can add members to the organization or skip and add members later. Click on "Complete setup".

#### Create a GitHub Repository
1. Go to the Organization, under Repositories tab click on "New repository".
2. Make sure the Owner field matches the Organization name. If not, select the correct Owner from the drop-down list.
3. Enter the name of the repository as "horizon-sdv".
4. Select "Public" for the repository visibility.   
   <img src="docs/images/org_repo_creation.png" width="550" />
5. Click on Create repository.

### Exercise #2f - Create GitHub Application
1. Go to the GitHub organization settings tab, click on Developer settings and from the list select "GitHub Apps".
2. Click on "New GitHub App".
   * Enter the GitHub App name as "horizon-sa"
   * Enter `https://github.com/` as the homepage URL.
   * Uncheck the "Active" checkbox Under Webhook.
   * Set permission for Contents as "Read-only". (This change will update Metadata permission to Read-only)   
      <img src="docs/images/github_app_repo_permission.png" width="450" />
3. Click on Create GitHub App.
4. To create a Private Key, 
   * Go to Organization, Settings, Developer settings, GitHub Apps and click on the "Edit" Button for "horizon-sa".
   * Click on "Generate a private key"   
      <img src="docs/images/github_app_private_key_1.png" width="450" />
   * Download and Save the `.pem` file to your machine locally.   
5. To note down the GitHub App ID, navigate to Organization, Settings, Developer settings, GitHub Apps and click on "horizon-sa" and note down the info as shown below   
   <img src="docs/images/github_app_id.png" width="300" />
6. Installing the GitHub App
   * Go to Organization, Settings, Developer settings, GitHub Apps and click on "horizon-sa".
   * Click on Install App.
   * Click on Install, select "All repositories" and click on "Install" again.
7. To verify the installation, go to Organization settings and click on GitHub Apps and it should look like below   
   <img src="docs/images/github_app_confirm_install.png" width="550" />

### Exercise #2g - Fork the repository
Below steps are for forking the **acn-horizon-sdv** repository to your GitHub organization.

1. On the **acn-horizon-sdv** GitHub page, click on fork drop-down list and select "Create a new fork".   
   <img src="docs/images/github_fork_repo_1.png" width="550" />
2. Select your GitHub organization and click on "Create fork".   
   <img src="docs/images/github_fork_repo_2.png" width="450" />
3. The repository should now be available on your GitHub Organization.

### Exercise #2h - Set up GitHub Environment
In this section we will be setting up the GitHub repository environment with the required environment secrets and variables.

#### Create a GitHub environment
1. Navigate to the forked repository on your GitHub organization and switch to the Settings tab.
2. From Settings tab, go to "Environments".   
   <img src="docs/images/github_repo_create_env.png" width="450" />
3. Click on "New environment" and name it "sbx" and click on "Configure environment".

#### Add Environment secrets
1. Clicking on "Add environment secrets" opens a new window where the secret Name and Value can be provided.   
   <img src="docs/images/github_repo_create_env_secret_1.png" width="400" />
2. After entering the details of the secret, click on "Add secret".   
   <img src="docs/images/github_repo_create_env_secret_2.png" width="400" />
3. Repeat the above steps and add the below **example** secrets (The secrets will be different for your setup)
   * GH_APP_ID: `1126617`
   * GH_APP_KEY:   
      ```
      -----BEGIN RSA PRIVATE KEY-----
      MIIEpQIBAAKCAQEAq7k1haW2sHkN5O8FMlAogBFZfE39MLuFad5DuOVGDrGmMidt
      ...
      yPSBViWgE2xQu7VVY0kxUZtS1h7h4yh1aZW9qvNqUy0K68aqDbVdgFg=
      -----END RSA PRIVATE KEY-----
      ```
   * GH_INSTALLATION_ID: `36369393`
   * GCP_SA: `github@sdvc-e84bd9c4.iam.gserviceaccount.com`
   * WIF_PROVIDER: projects/428278318385/locations/global/workloadIdentityPools/github/providers/github-provider
   * ARGOCD_INITIAL_PASSWORD: `myargocdpasswd`
   * CUTTLEFISH_VM_SSH_PRIVATE_KEY: (generate a key by using [ssh-keygen](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key))   
      ```
      -----BEGIN OPENSSH PRIVATE KEY-----   
      b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAACFwAAAAdzc2gtcn   
      ...   
      AIFvukjAZRbHAAAAB2plbmtpbnMBAgM=   
      -----END OPENSSH PRIVATE KEY-----
      ```
   * GERRIT_ADMIN_INITIAL_PASSWORD: `mygerritpasswd`
   * GERRIT_ADMIN_PRIVATE_KEY:   
      ```
      -----BEGIN OPENSSH PRIVATE KEY-----
      b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAaAAAABNlY2RzYS
      ...
      bgECAw==
      -----END OPENSSH PRIVATE KEY-----
      ```
   * JENKINS_INITIAL_PASSWORD: `myjenkinsinitpasswd`
   * KEYCLOAK_HORIZON_ADMIN_PASSWORD: `mykeycloadadminpasswd`
   * KEYCLOAK_INITIAL_PASSWORD: `mykeycloakpasswd`
4. Once all required credentials are setup, it should look like below   
   <img src="docs/images/github_repo_create_env_secret_3.png" width="400" />

#### Add Environment variables
1. Open repository settings and click on Environments, scroll down and click on "Add environment variable".   
   <img src="docs/images/github_repo_create_env_variable_1.png" width="400" />
2. Provide the Environment ID and Value as below (the value may be different for your GCP Project):
   * GCP_PROJECT_ID: `sdvc-e84bd9c4`
3. Once the Environment variable has been created, it will be visible as shown below   
   <img src="docs/images/github_repo_create_env_secret_2.png" width="400" />
   
### Exercise #2e - GitHub Actions workflow   
This section outlines the steps to trigger a GitHub Actions workflow. Before proceeding, it is recommended to fork this repository into your private GitHub account.   

The GitHub Actions Workflow has been configured to trigger if changes are either pushed to the `main` branch or any branch starting with `feature/` or `release/`. The workflow also gets trigger when pull requests are targeted toward the `main` branch. Provided, in both cases the changes are within `terraform/` directory.
   
> Note: Terraform apply workflows run only when changes are pushed or pull requests are targeted towards the `main` branch, otherwise Terraform plan only runs are triggered.

After forking the repository and configuring the required GCP IAM and Admin resources, as well as creating the necessary GitHub secrets, follow the steps below.   

#### Creating a new branch
It is recommend to create a new `feature/` or `release/` branch rather than working directly on the `main` branch. Follow the steps below for creating a new branch.
1. Clone the repository to your machine locally by clicking on the <img src="docs/images/github_clone_1.png" width="60" /> button, copy the HTTPS URL.
2. Run the below git command in your preferred directory to clone the repository   
   ``` 
   git clone <HTTPS_URL_OF_THE_REPOSITORY>
   ```
3. Create a new `feature/` or `release/` branch with the below command
   ```
   git checkout -b <feature/BRANCH_NAME>
   ```
If you prefer creating new branches via the GitHub GUI, follow the steps mention in this [document](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-and-deleting-branches-within-your-repository)   

#### Trigger Terraform plan workflow
Once a new feature branch has been created, follow the below steps to trigger a Terrafrom plan workflow run.
1. Edit the Terraform configuration files under `terraform/` directory.
2. Add, commit and push the changes with below commands
   ```
   git add .
   git commit -m "commit message"
   git push origin <feature/BRANCH_NAME>
   ```
3. This process should have triggered a Terraform plan GitHub Actions workflow.

#### Trigger Terraform apply workflow
The below steps require either a `feature/` or `release/` branch for creation of a pull request.
1. On the GitHub repository page, click on the Pull requests tab and click on <img src="docs/images/github_pr_1.png" width="85" />
2. Select `main` as the base branch and your `feature/` branch for compare.
3. Wait for the github workflow to check the pull request, you can check the created plan in the PR comments.
4. If a problem was found by the pull request checks, fix the issue.
5. If pull request check is successful, review the changes and merge the feature to the main branch.
4. This process should have triggered a Terraform apply GitHub Actions workflow.

#### Confirm the workflow run
If the aboves steps have been performed successfully, you can now head to the GitHub repository and check if the GitHub Actions workflow run has been triggered and a successful run should be as shown below   
<img src="docs/images/github_actions_workflow_1.png" width="500" />

## Exercise #3 - Verification
### Exercise #3a - Running test builds

## Exercise #4 - Troubleshooting



