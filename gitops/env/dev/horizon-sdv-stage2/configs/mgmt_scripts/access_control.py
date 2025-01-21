import google.auth

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

        
try:
    credentials, project = authentication()
except google.auth.exceptions.DefaultCredentialsError as e:
    print(f"There was an a problem with authentication. \n------\nError: {e}\n------")



