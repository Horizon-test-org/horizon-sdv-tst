import google.auth
import google.auth.credentials
from googleapiclient import discovery
import subprocess
import google.oauth2.credentials
from google.cloud import resourcemanager_v3
import json

def authentication():
    '''
    Make sure the gcloud CLI from https://cloud.google.com/sdk is installed.

    It uses Application Default Credentials.
    Automatically finds your credentials (like a service account or ADC credentials) based on the environment.
    Optionally provides the project ID associated with those credentials (if available).
    It simplifies authentication by checking common locations for credentials, such as:
        - The GOOGLE_APPLICATION_CREDENTIALS environment variable (for service account keys).
        - Credentials obtained from gcloud auth application-default login.
        - Default credentials provided by the metadata server (if running on a GCP resource like Compute Engine or Cloud Run).

    If not already done, runs `gcloud auth application-default login` command which opens browser to authenticate.

    If that fails, runs `gcloud auth application-default login --no-browser` command which lets authenticate without access to a web browser. 
    Generates a link which should be run on a machine with a web browser and copy the output back in the command line.

    '''
    operation_status = False

    try:
        creds, proj = google.auth.default()
    except google.auth.exceptions.DefaultCredentialsError as e:
        print(f"You are not authenticated yet. \n------\nError: {e}\n------")
        try:
            result = subprocess.run(["gcloud", "auth", "application-default", "login"], shell=True)
            result.check_returncode()
        except Exception as e:
            print(f"------\nError during authentication: {e}\n------")
            try:
                print("Another try to authenticate.")
                result = subprocess.run(["gcloud", "auth", "application-default", "login", "--no-browser"], shell=True)
                result.check_returncode()
            except Exception as e:
                print(f"------\nError during authentication: {e}\nFix it\n------")
            else:
                print("------\nYou are authenticated.\n------")
                operation_status = True
        else:
            print("------\nYou are authenticated.\n------")
            operation_status = True
    else:
        print("------\nYou are authenticated.\n------")
        operation_status = True
    
    return operation_status

def list_roles(service):
    '''
    Lists every predefined Role that IAM supports, or every custom role that is defined for an organization or project.
    '''
    request = service.roles().list()

    file_name = "Roles.txt"
    with open(file_name, "w") as file:
        while True:
            response = request.execute()
            for role in response.get('roles', []):
                file.write(f"{role}\n")
            request = service.roles().list_next(previous_request=request, previous_response=response)
            if request is None:
                break
    print(f"Roles are listed in a file '{file_name}'.")

def get_role(service, role):
    name = f"roles/{role}"
    request = service.roles().get(name=name)
    response = request.execute()
    print(response)

def get_users_by_roles():
    '''
    Retrieve all Roles + Users that are assigned to them.
    Returns dictionary: 
        role: [user1, user2]
    '''
    resource = f'projects/{PROJECT_ID}'
    users_by_roles = {}
    out_file_name = "Users_by_roles.json"
    client = resourcemanager_v3.ProjectsClient()
    policy = client.get_iam_policy(request={"resource": resource})

    
    for binding in policy.bindings:
        role = binding.role
        members = binding.members
        users_by_roles[role] = []
        for member in members:
            users_by_roles[role].append(member)

    with open(out_file_name, "w") as file:
        json.dump(users_by_roles, file)
    print(f"Users listed by roles are saved in a file '{out_file_name}'.")

    return users_by_roles



if __name__ == '__main__':

    operation_status = False

    # AUTHENTICATION #
    operation_status = authentication()

    # GETTING INO
    get_users_by_roles()


