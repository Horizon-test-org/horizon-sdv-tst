import google.auth
from googleapiclient import discovery
import subprocess

def authentication():
    '''
    It uses Application Default Credentials.
    Automatically finds your credentials (like a service account or ADC credentials) based on the environment.
    Optionally provides the project ID associated with those credentials (if available).
    It simplifies authentication by checking common locations for credentials, such as:
        - The GOOGLE_APPLICATION_CREDENTIALS environment variable (for service account keys).
        - Credentials obtained from gcloud auth application-default login.
        - Default credentials provided by the metadata server (if running on a GCP resource like Compute Engine or Cloud Run).

    If not already done, install the gcloud CLI from https://cloud.google.com/sdk and run `gcloud auth application-default login`

    '''
    credentials, project = google.auth.default()

    return credentials, project

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

if __name__ == '__main__':
    # AUTHENTICATION #
    try:
        credentials, project = authentication()
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
        else:
            print("------\nYou are authenticated.\n------")
    else:
        print("------\nYou are authenticated.\n------")

    #  #
    service = discovery.build('iam', 'v1', credentials=credentials)
    # list_roles(service=service)




