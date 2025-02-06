# ACN Horizon SDV

## Overview   
ACN Horizon SDV is designed to simplify the deployment and management of Android workloads on Google Kubernetes Engine clusters. By leveraging Infrastructure as Code (IaC) and GitOps, ensuring the cluster consistently matches the desired state, enabling scalable and efficient Android workload operations.

## Table of Contents
- [Overview](#overview)
- [Technologies](#technologies)
- [Project directories and files](#project-directories-and-files)
- [Section #1 - Prerequsites](#section-1---prerequsites)
- [Section #2 - GCP Foundation Setup (WIP)](#section-2---gcp-foundation-setup-wip)
   - [Section #2a - GCP Project details](#section-2a---gcp-project-details)
   - [Section #2b - Create a Bucket in GCP](#section-2b---create-a-bucket-in-gcp)
   - [Section #2c - Configure Google Cloud DNS](#section-2c---configure-google-cloud-dns)   
   - [Section #2d - Setting up GCP IAM & Admin for Terraform Workflow](#section-2d---setting-up-gcp-iam--admin-for-terraform-workflow)
   - [Section #2e - Create OAuth2 client and secret](#section-2e---create-oauth2-client-and-secret)
- [Section #3 - GitHub Foundation Setup (WIP)](#section-3---github-foundation-setup-wip)
   - [Section #3a - Create GitHub Organization and Repository](#section-3a---create-github-organization-and-repository)
   - [Section #3b - Create GitHub Application](#section-3b---create-github-application)
   - [Section #3c - Fork the Repository](#section-3c---fork-the-repository)
   - [Section #3d - Setup GitHub Environment](#section-3d---set-up-github-environment)
   - [Section #3e - Setup GitHub repository](#section-3e---setup-github-repository)
- [Section #4 - Setup GitHub Actions (WIP)](#section-4---setup-github-actions-wip)
   - [Section #4a - Setup Terraform Backend](#section-4a---setup-terraform-backend)
   - [Section #4b - Update Project Details](#section-4b---update-project-details)
   - [Section #4c - Trigger Terraform GitHub Actions Workflow](#section-4c---trigger-terraform-github-actions-workflow)
   - [Section #4d - Retrieve Load balancer details](#section-4d---retrieve-load-balancer-details)
- [Section #5 - Run the Cluster Apps (WIP)](#section-5---run-the-cluster-apps-wip)
   - [Section #5a - Setup Keycloak](#section-5a---setup-keycloak)
- [Section #6 - Run Android Workloads](#section-6---run-android-workloads)
   - [Section #6a - Browse CTS test results](#section-6a---browse-cts-test-results)
- [Section #7 - Troubleshooting](#section-7---troubleshooting)
- [LICENSE](#license)

## Technologies   
Technologies being used to provision the infrastructure along with the required applications for the GKE cluster.
* Google Cloud Platform - Cloud service provider for infrastructure provisioning.
* Terraform - IaC tool used to provision the infrastructure to maintain infrastructure consistency.
* GitHub - Source code management tool where infrastructure configuration, Kubernetes application manifests, workflows etc are stored.
* GitHub Actions - Continuous Integration (CI) platform used for automating the deployment process.
* Argo CD - Declarative, GitOps continuous delivery tool for Kubernetes.

## Project directories and files
The project is implemented in the following directories:

+ **.github/workflows** - Consists of GitHub Action workflows directing the operation of the CI build.
+ **gitops** - Kubernetes application manifests for Argo CD, contains desired state of the cluster.
+ **terraform** - IaC configuration files to provision the infrastructure required for the GKE cluster.
+ **workloads** - Jenkins workflow scripts for the pipeline build jobs.

## Section #1 - Prerequsites
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
   - Cloud Filestore Editorsetting-up-gcp-iam-and-admin-for-terraform-workflow
   - Storage Admin

### Terraform
* Access to edit the Terraform environment configuration files.
* IaC configuration files stored in GitHub repo.
* Infrastructure provisioned via CLI or GitHub Actions.

## Section #2 - GCP Foundation Setup (WIP)
This section covers creation and configuration of required Google Cloud Platform (GCP) services.

### Section #2a - GCP Project details
It is required to perform the checks mentioned in this section as this information will be required later in the setup process. The details shown below are only for example and may vary on your environment.
1. Default Google Compute Engine (GCE) Service Account:
   * On the console, click on IAM & Admin then, click on Service Accounts and confirm a Service Account for the GCE service is present.  
     <img src="docs/images/GCE_SA.png" width="500" />
2. Project ID:
   * On the console, click on IAM & Admin, click on Manage Resources and find the project details under the column **Name** and **ID** as below:   
     <img src="docs/images/GCP_project_id.png" width="500" />
   * It should look like: Name=`prj-s-agbg-gcp-sdv-team`, ID=`sdvc-2108202401`

### Section #2b - Create a Bucket in GCP
In the current GCP project, it is required to create a GCP Bucket to store data related to the infrastructure. Follow the below steps to create a Bucket.
1. On the GCP Console, navigate to Cloud Storage and click on Buckets.
2. Click on CREATE/CREATE BUCKET button.
3. Enter a globally unique name for the bucket. (Example: `prj-team-horizon-sdv-tf`)
4. Click on CREATE with default bucket configurations.

### Section #2c - Configure Google Cloud DNS
In this section, we will be retrieving DNS details required by the organizers for the DNS setup.

#### Retrieve Certificate's DNS Authz resources
1. On the Cloud console, navigate the Security, then scroll down and click on "Certificate Manager".
2. Under the CERTIFICATES tab, click on the Certificate's name which in this case is "horizon-sdv".
3. Now, scroll down to the bottom of the certificate details page which contains the required details about the "Certificate's DNS Authz resources".
4. From the Certificate's DNS Authz resources details table, copy the values of `DNS Record Name` and `DNS Record Data` as shown in below example.   
   <img src="docs/images/certificate_dns_authz_resource.png" width="650" />
5. Share the above Certificate's DNS Authz resources details with the Hackathon organizers which is required for populating the CNAME record in the DNS Zone.

### Section #2d - Setting up GCP IAM & Admin for Terraform Workflow
The first step for successfully running the GitHub Actions workflow is to set the required Identity and Access Management (IAM) resources on GCP for Terraform to be able to provision the infrastructure.   

Below are the resources which are required to be configured:   
1. Workload Identity Federation Pool and Provider
2. Create Service Account.
3. Binding the Service Account to the Workload Identity Federation.   
    
#### Creating a Workload Identity Federation pool and provider
1. Under IAM & Admin, select Workload Identity Federation.
2. Click on CREATE POOL and provide all the necesarry details
   - Enter Name as "github" and Provider Name as "github-provider".
   - Select OIDC as the provider.
   - Set the issuer to URL provided by GitHub (`https://token.actions.githubusercontent.com`) for GitHub Actions. [Click here for more information](https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/configuring-openid-connect-in-google-cloud-platform#adding-a-google-cloud-workload-identity-provider)
   - Configure Provider attributes as below:    
      * "google.subject" = "assertion.sub" and click on ADD MAPPING
      * "attribute.actor" = "assertion.actor" and click on ADD MAPPING
      * "attribute.aud" = "assertion.aud" and click on ADD MAPPING
      * "attribute.repository_owner" = "assertion.repository_owner" and click on ADD MAPPING
      * "attribute.repository" = "assertion.repository" and click on ADD MAPPING
   - Configure Attribute Conditions
      * Condition CEL = "assertion.repository_owner=='GITHUB_ORGANIZATION_NAME'"
   - Note down the Audience URL (shown just below Default audience) as below:
      * example: `"https://iam.googleapis.com/projects/966518152012/locations/global/workloadIdentityPools/github/providers/github-provider"`
   - Click save.
3. Workload Identity Federation Pool and Provider has now been created successfully.   
   <img src="docs/images/workload_identity_pool.png" width="650" />

#### Creating a Service Account
1. Under IAM & Admin, navigate to Service Accounts and click on CREATE SERVICE ACCOUNT.
2. Provide `github-sa` as the name for the Service Account.
3. Now, add Owner and Workload Identity User Role to the Service Account.
4. Click on save, your Service Account has now been created successfully.

#### Binding Service Account to the Workload Identity Provider
1. To bind this Service Account to the Workload Identity Provider, Navigate to the the Workload Identity Pool created earlier.
2. Click on GRANT ACCESS and select **Grant access using Service Account impersonation**.
3. Select `github-sa` as the Service Account.
4. Select principal attribute name as `repository_owner` and attribute value as `GITHUB_ORGANIZATION_NAME` and click on SAVE.
5. In the next window, select Provider as `github-provider` from the drop-down menu and set OIDC ID token path as `https://token.actions.githubusercontent.com`.
6. Download the config file.
7. Confirm the Service account has been bound successfully under CONNECTED SERVICE ACCOUNTS tab.   
   <img src="docs/images/workload_identity_pool_sa_bound.png" width="650" />

### Section #2e - Create OAuth2 client and secret
It is required to setup OAuth consent screen before creating the OAuth client and secret. Navigate to APIs & Services and follow the below mentioned steps

#### Setting up OAuth consent screen
Once in APIs & Services, click on OAuth consent screen to start the setup process.

1. Select User Type as "External" and click on CREATE.
2. Enter App name as "Horizon - SDV on GCP"
3. Provide a User support email.
4. Under App domain, provide a Application homepage link. For example, `https://team.horizon-sdv.scpmtk.com`.
5. Under Authorized domain, click on ADD DOMAIN and enter a relevant domain. For example, `scpmtk.com`
6. Provide email addresses under Developer contact information and click on SAVE AND CONTINUE.
7. On the next page, click on SAVE AND CONTINUE with default configurations.
8. In the Test users section, click on ADD USERS and add email addresses of users to enable access and click on SAVE AND CONTINUE.
9. Review the Summary and click on BACK TO DASHBOARD.   
   <img src="docs/images/oauth_consent_screen.png" width="450" />   

#### Create OAuth client ID
1. Under APIs & Services, click on Credentials.
2. Click on CREATE CREDENTIALS and select "OAuth client ID" from the drop-down list.
3. Select Application type as "Web application".
4. Provide Name as "Horizon".
5. Under Authorized redirect URIs enter the URI which points google endpoint of Keycloak. Example: `https://team.horizon-sdv.scpmtk.com/auth/realms/horizon/broker/google/endpoint`.
6. Clicking on CREATE opens a pop-up window containing client ID and secret which can be copied and saved locally to a file or download the credential detail as a JSON file.    
   <img src="docs/images/oauth_client_details.png" width="350" />
7. The credential will appear Under OAuth 2.0 Client IDs as below and credential details can be viewed and edited by clicking on the Name of the OAuth 2.0 Client ID.   
   <img src="docs/images/oauth2_list.png" width="490" />

## Section #3 - GitHub Foundation Setup (WIP)

### Section #3a - Create GitHub Organization and Repository
In this section, steps for creating a GitHub organization or repository are mentioned. Before we get started on creating a GitHub organization, it is required to have a GitHub account. If you do not have a Github account already, sign up [here](https://docs.github.com/en/get-started/start-your-journey/creating-an-account-on-github).

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

### Section #3b - Create GitHub Application
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
   <img src="docs/images/github_app_id.png" width="450" />
6. Installing the GitHub App
   * Go to Organization, Settings, Developer settings, GitHub Apps and click on "horizon-sa".
   * Click on Install App.
   * Click on Install, select "All repositories" and click on "Install" again.
7. To verify the installation, go to Organization settings and click on GitHub Apps and it should look like below   
   <img src="docs/images/github_app_confirm_install.png" width="550" />

### Section #3c - Fork the repository
Below steps are for forking the **acn-horizon-sdv** repository to your GitHub organization.

1. On the **acn-horizon-sdv** GitHub page, click on fork drop-down list and select "Create a new fork".   
   <img src="docs/images/github_fork_repo_1.png" width="550" />
2. Select your GitHub organization and click on "Create fork".   
   <img src="docs/images/github_fork_repo_2.png" width="450" />
3. The repository should now be available on your GitHub Organization.

### Section #3d - Set up GitHub Environment
In this section we will be setting up the GitHub repository environment with the required environment secrets and variables.

#### Create a GitHub environment
1. Navigate to the forked repository on your GitHub organization and switch to the Settings tab.
2. From Settings tab, go to "Environments".   
   <img src="docs/images/github_repo_create_env.png" width="450" />
3. Click on "New environment" and name it "team" and click on "Configure environment".

#### Add Environment secrets
1. Clicking on "Add environment secrets" opens a new window where the secret Name and Value can be provided.   
   <img src="docs/images/github_repo_create_env_secret_1.png" width="400" />
2. After entering the details of the secret, click on "Add secret".   
   <img src="docs/images/github_repo_create_env_secret_2.png" width="400" />
3. Repeat the above steps and add the below secrets (Replace `******` with your own password)
   * GH_APP_ID: `******`
   * GH_APP_KEY:   
      ```
      -----BEGIN RSA PRIVATE KEY-----
      MIIEpQIBAAKCAQEAq7k1haW2sHkN5O8FMlAogBFZfE39MLuFad5DuOVGDrGmMidt
      ...
      yPSBViWgE2xQu7VVY0kxUZtS1h7h4yh1aZW9qvNqUy0K68aqDbVdgFg=
      -----END RSA PRIVATE KEY-----
      ```
   * GH_INSTALLATION_ID: `******`
   * GCP_SA: `github@sdvc-2108202401.iam.gserviceaccount.com`
   * WIF_PROVIDER: projects/428278318385/locations/global/workloadIdentityPools/github/providers/github-provider
   * ARGOCD_INITIAL_PASSWORD: `******`
   * CUTTLEFISH_VM_SSH_PRIVATE_KEY: (generate a key by using [ssh-keygen](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key))   
      ```
      -----BEGIN OPENSSH PRIVATE KEY-----   
      b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAACFwAAAAdzc2gtcn   
      ...   
      AIFvukjAZRbHAAAAB2plbmtpbnMBAgM=   
      -----END OPENSSH PRIVATE KEY-----
      ```
   * GERRIT_ADMIN_INITIAL_PASSWORD: `******`
   * GERRIT_ADMIN_PRIVATE_KEY:   
      ```
      -----BEGIN OPENSSH PRIVATE KEY-----
      b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAaAAAABNlY2RzYS
      ...
      bgECAw==
      -----END OPENSSH PRIVATE KEY-----
      ```
   * JENKINS_INITIAL_PASSWORD: `******`
   * KEYCLOAK_HORIZON_ADMIN_PASSWORD: `******`
   * KEYCLOAK_INITIAL_PASSWORD: `******`
4. Once all of the required environment secrets are setup, it should look like below   
   <img src="docs/images/github_repo_create_env_secret_3.png" width="400" />

#### Add Environment variables
1. Open repository settings and click on Environments, scroll down and click on "Add environment variable".   
   <img src="docs/images/github_repo_create_env_variable_1.png" width="400" />
2. Provide the Environment ID and Value as below (the value may be different for your GCP Project):
   * GCP_PROJECT_ID: `sdvc-2108202401`
3. Once the Environment variable has been created, it will be visible as shown below   
   <img src="docs/images/github_repo_create_env_secret_2.png" width="400" />

### Section #3e - Setup GitHub repository
This section covers the steps to be followed for cloning the repository to the local machine and creating required branches.

#### Create GitHub Personal Access Token
Creating a GitHub Personal Access Token is required for securely accessing the repository.

1. In your profile settings, open Developer Settings.
2. Clicking on Personal access tokens opens a drop-down, select "Tokens (classic)".
3. Click on "Generate new token and select Generate new token (classic)".   
   <img src="docs/images/github_create_pat.png" width="450" />
4. Enter a suitable name for the token in the "Note" field and select Expiration of the token based on your requirement. (default set to 30 days)
5. Under "Select scopes", check all the checkboxes to enable all privileges and click on "Generate token".
6. Make sure to copy and save the token as it is displayed only once after token is created. 
7. Click on configure SSO, which opens a drop-down window and find an organization name between organizations that are "Available to authorize".   
   <img src="docs/images/github_pat_configure_sso_1.png" width="500" />
8. Click "Authorize" that corresponds to the GitHub organization name you are working in as shown in the above example.

#### Clone the repository
Before running the below commands, make sure [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) is installed and configured on your local machine.

1. On the repository homepage, click on <img src="docs/images/github_clone_1.png" width="60" /> button and copy the HTTPS URL.   
   <img src="docs/images/github_clone_repo_1.png" width="300" />
2. On your machine, navigate to your desired path and open the terminal and run the below command   
   ```
   git clone <REPOSIOTRY_URL>
   ```

#### Create a new branch
Create a new branch with `main` branch as the base.

1. Run the below command to make sure you are on the `main` branch.   
   ```
   git branch
   ```
2. If you are not on the main branch, run one of the below command to switch to the `main` branch.
   ```
   git checkout main
   ```   
   or   
   ```
   git switch main
   ```
3. Once you are on the `main` branch, run one of the below command to create a new branch and switch to it. Name it as `env/team`   
   ```
   git checkout -b env/team
   ```
   or
   ```
   git switch -c env/team
   ```
## Section #4 - Setup GitHub Actions (WIP)
Before running the Terraform GiHub Actions workflow, it is required to have the repository cloned locally and checked-out to a new branch as mentioned in the previous section. We will also be configuring a few files required for the GitHub Actions workflow.

### Section #4a - Setup Terraform Backend
Setting up the Terraform backend, the state data is mentioned in this section. This section depends on [Section #2b - Create a Bucket in GCP](#section-2b---create-a-bucket-in-gcp) to be completed.   

Edit the below mentioned attributes in the `backend.tf` located in the path `Terraform/env/backend.tf`
   ```
   bucket = "prj-team-horizon-sdv-tf"
   prefix = "prj-team-horizon-sdv-tf-state"
   ```

### Section #4b - Update Project Details
It is required to update the below mentioned attributes in the `main.tf` file located in the path `Terraform/env/main.tf`.   

```
sdv_default_compute_sa = "966518152012-compute@developer.gserviceaccount.com"
sdv_project = "sdvc-2108202401"
sdv_ssl_certificate_domain=team.horizon-sdv.com
```
Refer [Section #2a - GCP Project details](#section-2a---gcp-project-details) for the values required for `sdv_default_compute_sa` and `sdv_project`.

### Section #4c - Trigger Terraform GitHub Actions Workflow
1. Got to the GitHub repository.
2. Click on the "Actions" tab.
3. Select the "Terraform" workflow from the list.
4. Click on "Run workflow", select the branch you want to run and click on "Run workflow"   
   <img src="docs/images/github_actions_workflow_trigger.png" width="550" />

### Section #4d - Retrieve Load balancer details
The steps mentioned in this section is to be performed after the Terraform workflow is completed and the resources on GCP have been provisioned successfully.

1. On the GCP Console, search for "Network Services".
2. Click on Load balancing and under the LOAD BALANCER TAB, click on the Name of the Load balancer with Protocols set to "HTTPS" as shown in below example   
   <img src="docs/images/gcp_https_load_balancer_1.png" width="550" />
3. Under "Frontend", copy the IP Address details in the table as shown below example    
   <img src="docs/images/gcp_https_load_balancer_2.png" width="400" />

## Section #5 - Run the Cluster Apps (WIP)

### Section #5a - Setup Keycloak
Follow the steps mentioned in this section once the cluster is provisioned and is running successfully to configure Keycloak.

#### Configure Identity provider
1. Keycloak UI can be accessed here: `https://team.horizon-sbx.com/auth/`.
2. Login to Keycloak as admin with the credentials available in GitHub secrets as configured in section [Add Environment secrets](#add-environment-secrets).
3. Switch to the realm "Horizon" and click on "Identity providers".
4. Click "Add provider" and Select "Google" provider.
5. Redirect URI shall be the same which was set previously in the section [Create OAuth client ID](#create-oauth-client-id).
6. Enter the values for `Client ID` and `Client Secret` as mentiond in the step 7 of the section [Create OAuth client ID](#create-oauth-client-id).   
   <img src="docs/images/keycloak_identity_provider.png" width="650" />

#### Configure a new Authentication flow **(optional)**
1. Keycloak UI can be accessed here: `https://team.horizon-sbx.com/auth/`.
2. Login to Keycloak as admin with the credentials available in GitHub secrets as configured in section [Add Environment secrets](#add-environment-secrets).
3. Switch to the realm "Horizon" and select "Authentication" then click "Create flow" and name it as "broker link existing user".
4. Click "Add execution".
5. In the search box within the pop-up window, search for "Detect existing broker user" and click on "Add".   
   <img src="docs/images/keycloak_authentication_flow_1.png" width="400" />
6. Switch the value of "Requirement" field for the step "Detect existing broker user" to "Required" from the drop-down list as below   
   <img src="docs/images/keycloak_authentication_flow_2.png" width="400" />
7. Click on "Add step".
8. In the search box within the pop-up window, search for "Automatically set existing user" and click on "Add".   
   <img src="docs/images/keycloak_authentication_flow_3.png" width="400" />
9. Switch the value of "Requirement" field for the step "Automatically set existing user" to "Required" from the drop-down list as below   
   <img src="docs/images/keycloak_authentication_flow_4.png" width="400" />
10. Next, go to "Identity providers" and select "google".
11. Scroll down and look for "First login flow override". Switch the value of "First login flow override" to "broker link existing user" as shown below   
   <img src="docs/images/keycloak_authentication_flow_5.png" width="500" />
12. Finally, click on "Save".

## Section #6 - Run Android Workloads
### Section #6a - Browse CTS test results

## Section #7 - Troubleshooting

## LICENSE


