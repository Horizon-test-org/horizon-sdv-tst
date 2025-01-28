import google.auth
from googleapiclient import discovery
import subprocess
from google.cloud import resourcemanager_v3
import json
import os

PROJECT_ID = "sdva-2108202401"
CREDENTIALS_FILENAME = "application_default_credentials.json"


def check_credentials():
    '''
    Checks if credentials were already created.
    It simplifies authentication by checking common locations for credentials, such as:
        - The GOOGLE_APPLICATION_CREDENTIALS environment variable (for service account keys).
        - Credentials obtained from gcloud auth application-default login.
    '''
    # Check credentials from the GOOGLE_APPLICATION_CREDENTIALS environment variable.
    env_var = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS")
    if env_var:
        return True

    # Check credentials from the Cloud SDK.
    # Check if if the path is explicitly set, return that.
    env_var = os.environ.get("CLOUDSDK_CONFIG")
    if env_var:
        credentials_file_path = os.path.join(env_var, CREDENTIALS_FILENAME)
        if os.path.isfile(credentials_file_path):
            return True
    
    # Check credentials on Windows systems. Config should stored at %APPDATA%/gcloud
    if os.name == "nt":
        env_var = os.environ.get("APPDATA")
        if env_var:
            credentials_file_path = os.path.join(env_var, "gcloud", CREDENTIALS_FILENAME)
            if os.path.isfile(credentials_file_path):
                return True
    else: 
        # Check credentials on Non-windows system. They should be stored at ~/.config/gcloud
        credentials_file_path = os.path.join(os.path.expanduser("~"), ".config", "gcloud", CREDENTIALS_FILENAME)
        if os.path.isfile(credentials_file_path):
            return True

def authentication():
    '''
    Make sure the gcloud CLI from https://cloud.google.com/sdk is installed.

    It uses Application Default Credentials.
    Automatically finds your credentials (like a service account or ADC credentials) based on the environment.
    If not already done, runs `gcloud auth application-default login` command which opens browser to authenticate.
    If that fails, runs `gcloud auth application-default login --no-browser` command which lets authenticate without access to a web browser. 
    Generates a link which should be run on a machine with a web browser and copy the output back in the command line.

    Function returns tuple:
        - operation_status - True if operation succeeded
        - credentials - variable storing credentials
    '''
    operation_status = False
    credentials = None
    
    if check_credentials():
        print(f"Credentials already exist.")
        try:
            credentials, proj_id = google.auth.default()
            operation_status = True
        except google.auth.exceptions.DefaultCredentialsError as e:
            print(f"------\nError during authentication: {e}\n------")
        else:
            print("------\nYou are authenticated.\n------")
    else:
        print(f"There are no credentials. You will need to log in.")
        try:
            result = subprocess.run(["gcloud", "auth", "application-default", "login"], shell=True)
        except Exception as e:
            print(f"------\nError during authentication: {e}\n------")
        else:
            if check_credentials():
               credentials, proj_id = google.auth.default() 
               operation_status = True
               print("------\nYou are authenticated.\n------")
            else:
                print("Another try to authenticate.")
                try:
                    result = subprocess.run(["gcloud", "auth", "application-default", "login", "--no-launch-browser"], shell=True)
                    result.check_returncode()
                except Exception as e:
                    print(f"------\nError during authentication: {e}\nFix it\n------")
                else:
                    credentials, proj_id = google.auth.default() 
                    operation_status = True
                    print("------\nYou are authenticated.\n------")

    return operation_status, credentials


def save_data_to_json_file(out_file_name, data):
    with open(out_file_name, "w") as file:
        json.dump(data, file, indent=4)
    print(f"Data is saved in a file  '{out_file_name}'.")

def list_roles(service):
    '''
    Lists every predefined Role that IAM supports, or every custom role that is defined for an organization or project.
    '''
    request = service.roles().list()
    roles_ls = []

    while True:
        response = request.execute()
        for role in response.get('roles', []):
            roles_ls.append(role)
        request = service.roles().list_next(previous_request=request, previous_response=response)
        if request is None:
            break

    return roles_ls

def get_role_info(service, role):
    '''
    Returns info about specified role.
    '''
    name = f"roles/{role}"
    request = service.roles().get(name=name)
    response = request.execute()
    return response

def get_users_by_roles():
    '''
    Retrieve all Roles + Users that are assigned to them.
    Returns dictionary: 
        role: [user1, user2]
    '''
    resource = f'projects/{PROJECT_ID}'
    users_by_roles_dict = {}
    client = resourcemanager_v3.ProjectsClient()
    policy = client.get_iam_policy(request={"resource": resource})
    
    for binding in policy.bindings:
        role = binding.role
        members = binding.members
        users_by_roles_dict[role] = []
        for member in members:
            users_by_roles_dict[role].append(member)

    return users_by_roles_dict

def get_users_and_assigned_roles():
    '''
    Retrieve all Users and Roles that are assigned to them.
    Returns dictionary: 
        user: [role1, role2]
    '''
    users_by_roles = get_users_by_roles()
    users_and_roles_dict = {}

    for role, users in users_by_roles.items():
        for user in users:
            if user not in users_and_roles_dict:
                users_and_roles_dict[user] = []
            users_and_roles_dict[user].append(role)

    return users_and_roles_dict

if __name__ == '__main__':

    operation_status = False

    # AUTHENTICATION #
    operation_status, credentials = authentication()

    # Retreiving credentials #
    if operation_status:
        service = discovery.build(serviceName='iam', version='v1', credentials=credentials)

        # GETTING INO
        users_by_roles_dict = get_users_by_roles()
        save_data_to_json_file(out_file_name="Users_by_roles.json", data=users_by_roles_dict)

        users_and_roles_dict = get_users_and_assigned_roles()
        save_data_to_json_file(out_file_name="Users_with_roles.json", data=users_and_roles_dict)

        roles_ls = list_roles(service=service)
        save_data_to_json_file(out_file_name="Roles.json", data=roles_ls)

        role_info = get_role_info(service=service, role="storage.objectViewer")
        save_data_to_json_file(out_file_name="Role_info.json", data=role_info)

