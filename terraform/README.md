
# Terraform

Terraform documentation

Directories:

+ modules - implementation of the terraform modules
+ env - implementation for each environment
+ bash-scripts - files that are copied to the bastion host and executed.

## Implementation Workflow

+ Create a feature branch from main
+ Add the ticket implementation to the modules
+ Check the plan if it does what it is expected
+ Push the feature branch
+ Add a change to the env/main.tf file and push the feature branch
+ Check the github workflow plan result, when fail fix the issues found
+ Create a PR for the feature branch to main
+ Wait the github workflow to check the PR
+ Check the created plan in the PR comments
+ If a problem was found, fix the issue
+ If PR check is successful, merge the feature to the main branch
+ Check if the github workflow execution on main was successful
+ When not, fix the issue found, sometimes just rerun the github workflow to fix it.

# Terraform doc

The script uses docker to create the **terraform-doc.md** file, make sure that
your user can run docker.

To update the terraform-doc.md file for all the modules, execute the
**create-terraform-doc.sh** script.

```bash
./create-terraform-doc.sh
```
