
# ACN Horizon SDV

# Project directories and files

Tje project is implemented in the following directories:

+ .github/workflows
+ terraform
+ workloads



## Feature branch name

The format of a feature branch name should have the following format:

+ /feature/developer/jira-ticke-id

Sample of a feature branch created by Edson for the Jira ticket TAA-001:

+ /feature/eds/taa-001


## Release a new version

TODO: update documentation

+ on main branch
+ update env/(prod, staging, preprod, etc)/main.tf

    Test using env/dev

PR auf main
    run plan and apply on dev
    Check result

Create a version tag on the main branch that is used to create a release to a special environment (prod, preprod, stage etc)

Deployment of prod process
    Create a release branch
        release/prod/1.0.0



