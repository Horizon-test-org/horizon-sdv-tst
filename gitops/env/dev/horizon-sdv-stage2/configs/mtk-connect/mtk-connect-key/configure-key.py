import requests
from enum import Enum
import datetime
from dateutil.relativedelta import relativedelta
import base64
import json
from kubernetes import client, config

USERNAME = ""
KEY_VAL = ""
USER_ID = ""
OLD_KEY_ID = ''
OLD_KEY_VAL = ''

NAMESPACE = "mtk-connect"

SECRET_FILE = "secret.json"
SECRET_NAME = "mtk-connect-admin-key"

class API_REQUEST_OPT(Enum) :
  GET_VERSION = "https://dev.horizon-sdv.scpmtk.com/mtk-connect/api/v1/config/version"
  GET_CURRENT_USER = f"https://dev.horizon-sdv.scpmtk.com/mtk-connect/api/v1/users/{USER_ID}"
  CREATE_KEY = f"https://dev.horizon-sdv.scpmtk.com/mtk-connect/api/v1/users/{USER_ID}/keys"
  DELETE_KEY = f"https://dev.horizon-sdv.scpmtk.com/mtk-connect/api/v1/users/{USER_ID}/keys/"

def get_key_id(key_list, key_val_ref):
  """
  Searches the key_list and finds the key based on the provided beginning of the key value (key_start variable),
  returns id of the key.
  """   
  key_id = None
  
  try:
    for key in key_list:
      if key["key"][:8] == key_val_ref[:8]:
        key_id = key["id"]      
  except Exception as e:
    print(f"Exception occured when getting key id. \n\t{e}")

  return key_id

def perform_api_request(operation=API_REQUEST_OPT.GET_VERSION, delete_key_id="", is_delete_key_id=False):
  """
  Sends request to api. Possible actions are listed in API_REQUEST_OPT. 
  Returns result flag: True if operation was succesfull.
  """
  global KEY_VAL, OLD_KEY_VAL, OLD_KEY_ID
  result = False

  try:
    if operation is API_REQUEST_OPT.GET_VERSION:
      print("\nGet version of MTK Connect")
      response_api = requests.get(operation.value, auth=(USERNAME, KEY_VAL))
    elif operation is API_REQUEST_OPT.GET_CURRENT_USER:
      # Gets user data and stores value of the old key id, which will be used to delete the key
      print("\nGet current user data")
      response_api = requests.get(operation.value, auth=(USERNAME, KEY_VAL))
      if is_delete_key_id:
        OLD_KEY_ID = get_key_id(response_api.json()["data"]["keys"], OLD_KEY_VAL)

    elif operation is API_REQUEST_OPT.CREATE_KEY:
      print(f"\nCreate key for user id {USER_ID}")
      # New key settings: name, expiration date.
      # Current settings: name is empty, expiration date is set to 1 month after creation date (UTC+00:00 Timezone)
      key_expiration_date = datetime.datetime.now(tz=datetime.timezone.utc) + relativedelta(months=1)
      key_create_request_body = {
        "name": "",
        "expiryTime": f"{key_expiration_date.strftime('%Y-%m-%dT%H:%M:%SZ')}"
      }
      response_api = requests.post(operation.value, auth=(USERNAME, KEY_VAL), json=key_create_request_body)
      OLD_KEY_VAL = KEY_VAL
      KEY_VAL = response_api.json()["data"]["key"]
    elif operation is API_REQUEST_OPT.DELETE_KEY:
      print(f"\nDeleting key id: {OLD_KEY_ID}")
      response_api = requests.delete(operation.value+str(delete_key_id), auth=(USERNAME, KEY_VAL))

  except Exception as e:
    print(f"Exception occured when requesting response from API. \n\t{e}")
  else:
    reponse_category = response_api.status_code // 100
    if reponse_category == 2:
      print(f"Operation done succesfully!")
      result = True
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
    return result

def demo_api_connection(): # TODO: delete. Just for testing purposes
  
  perform_api_request()

  perform_api_request(operation=API_REQUEST_OPT.CREATE_KEY)

  print("\nTesting new key...")

  perform_api_request(operation=API_REQUEST_OPT.GET_CURRENT_USER)
  perform_api_request(operation=API_REQUEST_OPT.DELETE_KEY, delete_key_id=OLD_KEY_ID)

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

def retrieve_secret_value(secret_name, key):
    """
    Retrieves the value of a specific key from a Kubernetes Secret.
    """
    config.load_kube_config()
    v1 = client.CoreV1Api()
    print(f"\nRetrieving {key} value from secret.")

    try:
        secret = v1.read_namespaced_secret(name=secret_name, namespace=NAMESPACE)
        if key in secret.data:
            # Decode the base64 value
            value = base64.b64decode(secret.data[key]).decode().strip()
            print(f"Retrieved value for key '{key}': {value}")
            return value
        else:
            raise KeyError(f"Key '{key}' not found in secret '{secret_name}'.")
    except client.exceptions.ApiException as e:
        if e.status == 404:
            print(f"Secret '{secret_name}' not found in namespace '{NAMESPACE}'.")
        else:
            raise e

def update_secret_value(secret_name, new_value, key="password"):
    """
    Updates the value of a specific key in a Kubernetes Secret.
    Returns result flag: True if operation was succesfull.
    """
    result = False
    config.load_kube_config()
    v1 = client.CoreV1Api()
    
    try:
        # Fetch the existing secret
        secret = v1.read_namespaced_secret(name=secret_name, namespace=NAMESPACE)
        
        # Update the value of the specified key
        if secret.data is None:
            secret.data = {}  # Ensure `data` exists
        
        # Encode the new value to base64
        secret.data[key] = base64.b64encode(new_value.encode()).decode()
        
        # Update the secret in Kubernetes
        v1.replace_namespaced_secret(name=secret_name, namespace=NAMESPACE, body=secret)
        print(f"Updated key '{key}' in secret '{secret_name}' with new value.")
    except client.exceptions.ApiException as e:
        if e.status == 404:
            print(f"Secret '{secret_name}' not found in namespace '{NAMESPACE}'.")
        else:
            raise e
    else:
      result = True
    finally:
      return result

if __name__ == "__main__":
  print("Script start")

  USERNAME = retrieve_secret_value(SECRET_NAME, "username")
  KEY_VAL = retrieve_secret_value(SECRET_NAME, "password")
  USER_ID = retrieve_secret_value(SECRET_NAME, "user_id")

  print(f"-----\n\tUSERNAME: {USERNAME}, KEY: {KEY_VAL}, USER ID: {USER_ID}.")
  print(f"\tUSERNAME: {type(USERNAME)}, KEY: {type(KEY_VAL)}, USER ID: {type(USER_ID)}.\n------")

  operation_result = perform_api_request(operation=API_REQUEST_OPT.CREATE_KEY)

  if operation_result:
    operation_result = update_secret_value(SECRET_NAME, KEY_VAL)

  if operation_result:
    operation_result = perform_api_request(operation=API_REQUEST_OPT.GET_CURRENT_USER, is_delete_key_id=True)

  if operation_result:
    operation_result = perform_api_request(operation=API_REQUEST_OPT.DELETE_KEY, delete_key_id=OLD_KEY_ID)

  if operation_result:
    operation_result = perform_api_request(operation=API_REQUEST_OPT.GET_CURRENT_USER)

  print("Script end")
