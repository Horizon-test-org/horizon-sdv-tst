import requests
from enum import Enum
import datetime
from dateutil.relativedelta import relativedelta
import base64
import json
from kubernetes import client, config

USERNAME = 
USER_ID = 
KEY_VAL = 
KEY_ID = ''

NAMESPACE = "mtk-connect"

SECRET_FILE = "secret.json"
SECRET_NAME = "mtk-connect-admin-key"

class API_REQUEST_OPT(Enum) :
  GET_VERSION = "https://dev.horizon-sdv.scpmtk.com/mtk-connect/api/v1/config/version"
  GET_CURRENT_USER = "https://dev.horizon-sdv.scpmtk.com/mtk-connect/api/v1/users/me"
  CREATE_KEY = f"https://dev.horizon-sdv.scpmtk.com/mtk-connect/api/v1/users/{USER_ID}/keys"
  DELETE_KEY = f"https://dev.horizon-sdv.scpmtk.com/mtk-connect/api/v1/users/{USER_ID}/keys/"

# New key settings: name, expiration date.
# Current settings: name is empty, expiration date is set to 1 month after creation date (UTC+00:00 Timezone)
KEY_EXPIRATION_DATE = datetime.datetime.now(tz=datetime.timezone.utc) + relativedelta(months=1)
KEY_CREATE_REQUEST_BODY = {
  "name": "",
  "expiryTime": f"{KEY_EXPIRATION_DATE.strftime('%Y-%m-%dT%H:%M:%SZ')}"
}

def connect_to_api(operation=API_REQUEST_OPT.GET_VERSION, request_body=None, delete_key_id=""):
  global KEY_VAL, KEY_ID
  try:
    if operation is API_REQUEST_OPT.GET_VERSION:
      response_api = requests.get(operation.value, auth=(USERNAME, KEY_VAL))
    elif operation is API_REQUEST_OPT.GET_CURRENT_USER:
      response_api = requests.get(operation.value, auth=(USERNAME, KEY_VAL))
    elif operation is API_REQUEST_OPT.CREATE_KEY:
      response_api = requests.post(operation.value, auth=(USERNAME, KEY_VAL), json=request_body)
      KEY_VAL = response_api.json()["data"]["key"]
      KEY_ID = response_api.json()["data"]["id"]
    elif operation is API_REQUEST_OPT.DELETE_KEY:
      response_api = requests.delete(operation.value+str(delete_key_id), auth=(USERNAME, KEY_VAL))
    

  except Exception as e:
    print(f"Exception occured when requesting response from API. \n\t{e}")
  else:
    reponse_category = response_api.status_code // 100
    if reponse_category == 2:
      print(f"Operation done succesfully!")
    elif reponse_category == 3:
      print(f"Redirection!")
    elif reponse_category == 4:
      print(f"Client Error!")
    elif reponse_category == 5:
      print(f"Server Error!")
    else:
      print(f"There was a problem!")
  finally:
    print(f"Status code: {response_api.status_code} \nResponse from API: \n\t{response_api.text}")
    print("Request to API finished")

def demo_api_connection(): # TODO: delete. Just for testing purposes
  print("\nGet version of MTK Connect")
  connect_to_api()

  print(f"\nOld key id: {KEY_ID} \tval: {KEY_VAL}")

  print(f"\nCreate key for user id {USER_ID}")
  connect_to_api(operation=API_REQUEST_OPT.CREATE_KEY, request_body=KEY_CREATE_REQUEST_BODY)

  print(f"\nNew key id: {KEY_ID} \tval: {KEY_VAL}")

  print("\nTesting new key...")

  print("\nGet current user")
  connect_to_api(operation=API_REQUEST_OPT.GET_CURRENT_USER)

  print(f"\nDeleting key id: {KEY_ID} \tval: {KEY_VAL}")
  connect_to_api(operation=API_REQUEST_OPT.DELETE_KEY, delete_key_id=KEY_ID)

def create_secret_from_json(json_file):
  """
  Reads a secret JSON file, transforms stringData to base64-encoded data, 
  and creates or updates the Kubernetes Secret.
  """

  with open(json_file, 'r') as f:
    secret_data = json.load(f)

  # Ensure `stringData` exists in the JSON and process it
  if "stringData" in secret_data:
    encoded_data = {
      # Encode the `stringData` values to base64 and replace it with `data`
        key: base64.b64encode(value.encode()).decode()
        for key, value in secret_data["stringData"].items()
    }
    secret_data["data"] = encoded_data
    del secret_data["stringData"]  # Remove `stringData` as it's now replaced
  else:
    raise ValueError("The JSON does not contain a 'stringData' field.")
  
  print(f"encoded secret: \n\t{secret_data}")

# Create the secret object using the Kubernetes Python client
  secret = client.V1Secret(
    api_version=secret_data.get("apiVersion", "v1"),
    kind=secret_data.get("kind", "Secret"),
    metadata=client.V1ObjectMeta(
        name=secret_data["metadata"]["name"],
        namespace=secret_data["metadata"].get("namespace", "default"),
        labels=secret_data["metadata"].get("labels"),
    ),
    type=secret_data.get("type", "Opaque"),
    data=secret_data["data"]
  )

  print(f"secret: \n{secret}")

  # Load Kubernetes configuration
  config.load_kube_config()
  v1 = client.CoreV1Api()
    
  # Create or update the secret in Kubernetes
  try:
    v1.create_namespaced_secret(namespace=secret.metadata.namespace, body=secret)
    print(f"Secret '{secret.metadata.name}' created successfully in namespace '{secret.metadata.namespace}'!")
  except client.exceptions.ApiException as e:
    if e.status == 409:  # Secret already exists
      print(f"Secret '{secret.metadata.name}' already exists.")
    else:
      raise e

def retrieve_secret_value(secret_name, key="password"):
    """
    Retrieves the value of a specific key from a Kubernetes Secret.
    """
    config.load_kube_config()
    v1 = client.CoreV1Api()
    
    try:
        secret = v1.read_namespaced_secret(name=secret_name, namespace=NAMESPACE)
        if key in secret.data:
            # Decode the base64 value
            value = base64.b64decode(secret.data[key]).decode()
            print(f"Retrieved value for key '{key}': {value}")
            return value
        else:
            raise KeyError(f"Key '{key}' not found in secret '{secret_name}'.")
    except client.exceptions.ApiException as e:
        if e.status == 404:
            print(f"Secret '{secret_name}' not found in namespace '{NAMESPACE}'.")
        else:
            raise e


if __name__ == "__main__":
  print("Script start")

  # create_secret_from_json(SECRET_FILE)

  KEY_VAL = retrieve_secret_value(SECRET_NAME)


  print("Script end")