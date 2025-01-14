import requests
import datetime
from dateutil.relativedelta import relativedelta
import base64
import json
from kubernetes import client, config
import argparse
import os

USERNAME = ""
KEY_VAL = ""
USER_ID = ""
URL_DOMAIN = ""
OLD_KEY_ID = ''
OLD_KEY_VAL = ''

NAMESPACE = "mtk-connect"
SECRET_NAME = "mtk-connect-admin-key"

API_REQUEST_OPT = {
  "GET_VERSION": "https://URL_DOMAIN/mtk-connect/api/v1/config/version",
  "GET_CURRENT_USER": "https://URL_DOMAIN/mtk-connect/api/v1/users/USER_ID",
  "CREATE_KEY": "https://URL_DOMAIN/mtk-connect/api/v1/users/USER_ID/keys",
  "DELETE_KEY": "https://URL_DOMAIN/mtk-connect/api/v1/users/USER_ID/keys/",
  "GET_USER_DETAILS": "https://URL_DOMAIN/mtk-connect/api/v1/users?q=%7B%22username%22%3A%20%22marta.kania%40accenture.com%22%7D" #users?q=%7B%22username%22%3A%20%22mtk-connect-admin%22%7D"
}

def update_request_urls(upd_domain=False, upd_user_id=False):
  global API_REQUEST_OPT
  for key in API_REQUEST_OPT:
    if upd_domain:
      API_REQUEST_OPT[key] = API_REQUEST_OPT[key].replace("URL_DOMAIN", f"{URL_DOMAIN}")
    if upd_user_id:
      API_REQUEST_OPT[key] = API_REQUEST_OPT[key].replace("USER_ID", f"{USER_ID}")
  return True

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

def perform_api_request(operation=API_REQUEST_OPT["GET_VERSION"], delete_key_id="", is_delete_key_id=False):
  """
  Sends request to api. Possible actions are listed in API_REQUEST_OPT. 
  Returns result flag: True if operation was succesfull.
  """
  global KEY_VAL, OLD_KEY_VAL, OLD_KEY_ID, USER_ID
  result = False

  try:
    if operation == "GET_VERSION":
      print("\nGet version of MTK Connect")
      response_api = requests.get(API_REQUEST_OPT["GET_VERSION"], auth=(USERNAME, KEY_VAL))

    elif operation == "GET_CURRENT_USER":
      # Gets user data and stores value of the old key id, which will be used to delete the key
      print("\nGet current user data")
      response_api = requests.get(API_REQUEST_OPT["GET_CURRENT_USER"], auth=(USERNAME, KEY_VAL))
      if is_delete_key_id and (response_api.status_code // 100 == 2):
        OLD_KEY_ID = get_key_id(response_api.json()["data"]["keys"], OLD_KEY_VAL)

    elif operation == "CREATE_KEY":
      print(f"\nCreate key for user id {USER_ID}")
      # New key settings: name, expiration date.
      # Current settings: name is empty, expiration date is set to 1 month after creation date (UTC+00:00 Timezone)
      key_expiration_date = datetime.datetime.now(tz=datetime.timezone.utc) + relativedelta(months=1)
      key_create_request_body = {
        "name": "",
        "expiryTime": f"{key_expiration_date.strftime('%Y-%m-%dT%H:%M:%SZ')}"
      }
      response_api = requests.post(API_REQUEST_OPT["CREATE_KEY"], auth=(USERNAME, KEY_VAL), json=key_create_request_body)
      if response_api.status_code // 100 == 2:
        KEY_VAL = response_api.json()["data"]["key"]
        OLD_KEY_VAL = KEY_VAL

    elif operation == "DELETE_KEY":
      print(f"\nDeleting key id: {OLD_KEY_ID}")
      response_api = requests.delete(API_REQUEST_OPT["DELETE_KEY"]+str(delete_key_id), auth=(USERNAME, KEY_VAL))

    elif operation == "GET_USER_DETAILS":
      print("\nRetreiving detail info for mtk-connect-admin user")
      response_api = requests.get(API_REQUEST_OPT["GET_USER_DETAILS"], auth=(USERNAME, KEY_VAL))
      if response_api.status_code // 100 == 2:
        USER_ID = response_api.json()["data"][0]["id"]

    else:
      raise KeyError(f"Operation '{operation}' not found.")

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

    print(f"Status code: {response_api.status_code} \nResponse from API: \n\t{response_api.text}")
    print("Request to API finished")
    return result

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

def retrieve_secret_value(secret_key):
  """
  Retrieves the value of a specific key from a Kubernetes Secret.
  """
  secret_value = os.getenv(secret_key).strip()
  if secret_value:
    print(f"Retrieved secret value from environment variable: {secret_value}")
  else:
    print("Failed to retrieve secret value from environment variable.")
  return secret_value

def update_secret_value(secret_name, new_value, key="password"):
  """
  Updates the value of a specific key in a Kubernetes Secret.
  Returns result flag: True if operation was succesfull.
  """
  result = False
  try:
    config.load_incluster_config()
    print("Using in-cluster configuration.")
  except config.ConfigException:
    config.load_kube_config()
    print("Using kubeconfig file.")
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

  operation_result = False

  parser = argparse.ArgumentParser(description="Run the script with parameters. Required parameters: domain")
  parser.add_argument("--api-domain", type=str, required=True, help="API domain")
  args = parser.parse_args()
  URL_DOMAIN = vars(args)["api_domain"]
  USERNAME = retrieve_secret_value("MTK_KEY_UPD_USERNAME")
  KEY_VAL = retrieve_secret_value("MTK_KEY_UPD_PASSWORD")

  if (USERNAME and KEY_VAL):
    operation_result = update_request_urls(upd_domain=True)

  if operation_result:
    operation_result = perform_api_request(operation="GET_USER_DETAILS")

  if operation_result:
    operation_result = update_request_urls(upd_user_id=True)

  if operation_result:
    operation_result = perform_api_request(operation="CREATE_KEY")

  if operation_result:
    operation_result = update_secret_value(SECRET_NAME, KEY_VAL)

  if operation_result:
    operation_result = perform_api_request(operation="GET_CURRENT_USER", is_delete_key_id=True)

  if operation_result:
    operation_result = perform_api_request(operation="DELETE_KEY", delete_key_id=OLD_KEY_ID)

  if operation_result:
    operation_result = perform_api_request(operation="GET_CURRENT_USER")

  print("Script end")
