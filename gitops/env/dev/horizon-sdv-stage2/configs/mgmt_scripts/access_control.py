"""@package docstring
Access control script for a Platform Administrator.
Author marta.kania@accenture.com
"""
import json
import os
import argparse
import subprocess
from enum import Enum, auto
import google.auth
from googleapiclient import discovery
from google.cloud import resourcemanager_v3

### Just for debug purposes
GET_INFO = False
ADD_ROLE_TO_USER = False
REMOVE_ROLE_TO_USER = False
###

PROJECT_ID = "sdvc-2108202401"  # "sdva-2108202401"
CREDENTIALS_FILENAME = "application_default_credentials.json"
USER_KEYWORD = "user:"

# CONST VALUES FOR JSON FILE OPERATIONS LIST
class OperationsKey(Enum):
    OPERATION = "operation"
    USER = "user"
    ROLE = "role"
class Operations(Enum):
    GET_ALL_USERS = auto()
    GET_USER = auto()
    GET_ALL_ROLES = auto()
    GET_ALL_ROLES_WITH_USERS = auto()
    GET_ROLE_INFO = auto()
    SET_ROLE_TO_USER = auto()
    DELETE_ROLE_FROM_USER = auto()

def check_credentials():
    '''
    Checks if credentials were already created.
    It simplifies authentication by checking common locations for credentials, such as:
        - The GOOGLE_APPLICATION_CREDENTIALS environment variable (for service account keys).
        - Credentials obtained from gcloud auth application-default login.
    '''
    # Check credentials from the GOOGLE_APPLICATION_CREDENTIALS environment variable.
    if os.environ.get("GOOGLE_APPLICATION_CREDENTIALS"):
        return True

    # Check credentials from the Cloud SDK.
    # Check if if the path is explicitly set, return that.
    env_var = os.environ.get("CLOUDSDK_CONFIG")
    if env_var:
        credentials_file_path = os.path.join(env_var, CREDENTIALS_FILENAME)
        if os.path.isfile(credentials_file_path):
            return True
    
    # Check credentials on Windows systems. Config should stored at %APPDATA%/gcloud
    if os.name != "nt":
        # Check credentials on Non-windows system. They should be stored at ~/.config/gcloud
        credentials_file_path = os.path.join(os.path.expanduser("~"), ".config", "gcloud", CREDENTIALS_FILENAME)
        if os.path.isfile(credentials_file_path):
            return True
    else: 
        env_var = os.environ.get("APPDATA")
        if env_var:
            credentials_file_path = os.path.join(env_var, "gcloud", CREDENTIALS_FILENAME)
            if os.path.isfile(credentials_file_path):
                return True
            
    return False

def authentication():
    '''
    Make sure the gcloud CLI from https://cloud.google.com/sdk is installed.

    It uses Application Default Credentials.
    Automatically finds your credentials (like a service account or ADC credentials) based on the environment.
    If not already done, runs `gcloud auth application-default login` command which opens browser to authenticate.
    If that fails, runs `gcloud auth application-default login --no-browser` command which lets authenticate without access to a web browser. 
    Generates a link which should be run on a machine with a web browser and copy the output back in the command line.

    Function returns tuple:
        - return_status - True if operation succeeded
        - credentials - variable storing credentials
    '''
    return_status = False
    credentials = None
    
    print("------")
    if check_credentials():
        print("Credentials already exist.")
        try:
            credentials, proj_id = google.auth.default()
            return_status = True
        except google.auth.exceptions.DefaultCredentialsError as e:
            print(f"Error during authentication: {e}")
        else:
            print("You are authenticated.")
    else:
        print(f"There are no credentials. You will need to log in.")
        try:
            subprocess.run(["gcloud", "auth", "application-default", "login"], shell=True)
        except Exception as e:
            print(f"Error during authentication: {e}")
        else:
            if check_credentials():
               credentials, proj_id = google.auth.default() 
               return_status = True
               print("You are authenticated.")
            else:
                print("Another try to authenticate.")
                try:
                    result = subprocess.run(["gcloud", "auth", "application-default", "login", "--no-launch-browser"], shell=True)
                    result.check_returncode()
                except Exception as e:
                    print(f"""There were three attempts to authenticate: 
                          1. Automatically check saved credentials.
                          2. Login with browser.
                          3. Provide an url to login using browser on machine with connection to internet. 
                          Error during authentication.\n{e}\nFix it""")
                    raise
                else:
                    credentials, proj_id = google.auth.default() 
                    return_status = True
                    print("You are authenticated.")

    return return_status, credentials

def save_data_to_json_file(out_file_name, data):
    with open(out_file_name, "w") as file:
        json.dump(data, file, indent=4)
    print(f"Data is saved in a file  '{out_file_name}'.")

def get_roles_list(service):
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
            if user.startswith(USER_KEYWORD):
                if user not in users_and_roles_dict:
                    users_and_roles_dict[user] = []
                users_and_roles_dict[user].append(role)

    return users_and_roles_dict

def get_particular_user_roles(user):
    '''
    Retrieve roles assigned to particular user.
    Returns list of roles.
    '''
    users_by_roles = get_users_by_roles()
    user_roles_info_ls = []

    for role, users in users_by_roles.items():
        for u in users:
            if user in u:
                user_roles_info_ls.append(role)

    return user_roles_info_ls

def add_role_to_user(user, role):
    '''
    Add role for given user.
    Parameters:
        - user: provide user email
        - role: provide role id
    Returns operation status. If operation is successful return True
    '''
    resource = f'projects/{PROJECT_ID}'
    client = resourcemanager_v3.ProjectsClient()
    policy = client.get_iam_policy(request={"resource": resource})
    role = f"roles/{role}"
    
    for binding in policy.bindings:
        if binding.role == role and f"{USER_KEYWORD}{user}" in binding.members:
            print(f"User {user} already has the role {role}.")
            return True
            
    binding = policy.bindings.add()
    binding.role = role 
    binding.members.append(f"{USER_KEYWORD}{user}")

    client.set_iam_policy(
        request={
            "resource": resource,
            "policy": policy
            }
        )

    print(f"Added role {role} to user {user} in project {PROJECT_ID}.")
    return True

def remove_role_from_user(user_email, role_id):
    '''
    Removes a specific role from a user in a Google Cloud project.

    Args:
        user_email (str): The email of the user.
        role_id (str): The role to remove (e.g., "roles/viewer").
        project_id (str): The Google Cloud Project ID.

    Returns:
        None
    '''
    resource = f"projects/{PROJECT_ID}"
    client = resourcemanager_v3.ProjectsClient()
    policy = client.get_iam_policy(request={"resource": resource})
    role_id = f"roles/{role_id}"

    for binding in policy.bindings:
        if binding.role == role_id:
            if f"{USER_KEYWORD}{user_email}" in binding.members:
                binding.members.remove(f"{USER_KEYWORD}{user_email}")
                print(f"Removed {user_email} from {role_id}")
            # Only keep bindings that still have members
            if not binding.members:
                policy.bindings.remove(binding)

    # Update policy bindings
    client.set_iam_policy(
        request={
            "resource": resource,
            "policy": policy
        }
    )

    print(f"Updated IAM policy for project {PROJECT_ID}.")

def operations_handler(operation, service):
    '''
    Handling operations.
    Input variable: 
        operation - type class Operations() 
    '''
    return_status = False

    if operation[OperationsKey.OPERATION.value] in Operations.__members__:
        print(f"Handling operation {operation}")
        
        if operation[OperationsKey.OPERATION.value] == Operations.GET_ALL_USERS.name:
            users_and_roles_dict = get_users_and_assigned_roles()
            save_data_to_json_file(out_file_name="Users_with_roles.json", data=users_and_roles_dict)
            return_status = True
            
        elif operation[OperationsKey.OPERATION.value] == Operations.GET_USER.name:
            user_roles_info_ls = get_particular_user_roles(user=operation[OperationsKey.USER.value])
            save_data_to_json_file(out_file_name="User_info.json", data=user_roles_info_ls)
            return_status = True
            
        elif operation[OperationsKey.OPERATION.value] == Operations.GET_ALL_ROLES.name:
            roles_ls = get_roles_list(service=service)
            save_data_to_json_file(out_file_name="Roles.json", data=roles_ls)
            return_status = True
        
        elif operation[OperationsKey.OPERATION.value] == Operations.GET_ALL_ROLES_WITH_USERS.name:
            users_by_roles_dict = get_users_by_roles()
            save_data_to_json_file(out_file_name="Users_by_roles.json", data=users_by_roles_dict)
            return_status = True
                
        elif operation[OperationsKey.OPERATION.value] == Operations.GET_ROLE_INFO.name:
            role_info = get_role_info(service=service, role=operation[OperationsKey.ROLE.value])
            save_data_to_json_file(out_file_name="Role_info.json", data=role_info)
            return_status = True
            
        elif operation[OperationsKey.OPERATION.value] == Operations.SET_ROLE_TO_USER.name:
            add_role_to_user(user=operation[OperationsKey.USER.value], role=operation[OperationsKey.ROLE.value])
            return_status = True
            
        elif operation[OperationsKey.OPERATION.value] == Operations.DELETE_ROLE_FROM_USER.name:
            remove_role_from_user(user_email=operation[OperationsKey.USER.value], role_id=operation[OperationsKey.ROLE.value])
            return_status = True
            
    else:
        print(f"There is no such operation as {operation}")

    return return_status
    
def retrieve_operations_list_from_json(operations_file_path, service):
    '''
    Handling json file which contains list of users and operaton that shall be performed on them.
    '''
    print("------")
    print(f"I will look through the list of operations in the provided file: {operations_file_path}")
    
    with open(operations_file_path, "r") as file:
        operations_list = json.load(file)
            
    success_score = 0
    for op in operations_list:
        if operations_handler(op, service):
            success_score += 1
        
    print(f"\nThere were: {len(operations_list) - success_score} incorrect operations.")
    
def script_arguments_handler(service):
    '''
    Handle arguments provided to the script.
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument("-op", "--operations_list", help="Path to json file which contains operations list to perform")
    args = parser.parse_args()

    if args.operations_list:
        retrieve_operations_list_from_json(operations_file_path=args.operations_list, service=service)


if __name__ == '__main__':

    # AUTHENTICATION #
    operation_status, credentials = authentication()
    
    # HANDLING OPERATIONS FROM JSON #
    if operation_status: 
        service = discovery.build(serviceName='iam', version='v1', credentials=credentials)
        script_arguments_handler(service=service)
        
    if operation_status:
        
        # GETTING INO
        if GET_INFO:
            users_by_roles_dict = get_users_by_roles()
            save_data_to_json_file(out_file_name="Users_by_roles.json", data=users_by_roles_dict)

            users_and_roles_dict = get_users_and_assigned_roles()
            save_data_to_json_file(out_file_name="Users_with_roles.json", data=users_and_roles_dict)

            roles_ls = get_roles_list(service=service)
            save_data_to_json_file(out_file_name="Roles.json", data=roles_ls)

            role_info = get_role_info(service=service, role="storage.objectViewer")
            save_data_to_json_file(out_file_name="Role_info.json", data=role_info)

            user_roles_info_ls = get_particular_user_roles(user="marta.kania@accenture.com")
            save_data_to_json_file(out_file_name="User_info.json", data=user_roles_info_ls)

        # GRANTING A ROLE TO USER
        if ADD_ROLE_TO_USER:
            user_roles_info_ls = get_particular_user_roles(user="marta.kania@accenture.com")
            save_data_to_json_file(out_file_name="User_info_adding_role_before.json", data=user_roles_info_ls)

            add_role_to_user("marta.kania@accenture.com", "storage.objectViewer")

            user_roles_info_ls = get_particular_user_roles(user="marta.kania@accenture.com")
            save_data_to_json_file(out_file_name="User_info_adding_role_after.json", data=user_roles_info_ls)
            
            
        
        # REMOVING ROLE FROM A USER
        if REMOVE_ROLE_TO_USER:
            user_roles_info_ls = get_particular_user_roles(user="marta.kania@accenture.com")
            save_data_to_json_file(out_file_name="User_info_deleteing_before.json", data=user_roles_info_ls)
            
            users_by_roles_dict = get_users_by_roles()
            save_data_to_json_file(out_file_name="Users_by_roles_delete_before.json", data=users_by_roles_dict)

            remove_role_from_user("marta.kania@accenture.com", "storage.objectViewer")

            user_roles_info_ls = get_particular_user_roles(user="marta.kania@accenture.com")
            save_data_to_json_file(out_file_name="User_info_deleteing_after.json", data=user_roles_info_ls)
            
            users_by_roles_dict = get_users_by_roles()
            save_data_to_json_file(out_file_name="Users_by_roles_delete_after.json", data=users_by_roles_dict)


