import requests
from enum import Enum
import datetime
from dateutil.relativedelta import relativedelta

USERNAME = 
USER_ID = 
KEY_VAL = 
KEY_ID = ''

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
  "expiryTime": f"{KEY_EXPIRATION_DATE.strftime("%Y-%m-%dT%H:%M:%SZ")}"
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


print("Script start")
print("\nGet version of MTK Connect")
connect_to_api()
print(f"\nCreate key for user id {USER_ID}")
connect_to_api(operation=API_REQUEST_OPT.CREATE_KEY, request_body=KEY_CREATE_REQUEST_BODY)

print("\nTesting new key...")

print("\nGet current user")
connect_to_api(operation=API_REQUEST_OPT.GET_CURRENT_USER)

print(f"\nDeleting key id: {KEY_ID} \tval: {KEY_VAL}")
connect_to_api(operation=API_REQUEST_OPT.DELETE_KEY, delete_key_id=KEY_ID)


