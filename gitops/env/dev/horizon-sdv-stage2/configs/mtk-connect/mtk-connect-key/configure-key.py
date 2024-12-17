import requests
from enum import Enum
import datetime
from dateutil.relativedelta import relativedelta

USERNAME = 
USER_ID = 
KEY = 

class API_REQUEST_OPT(Enum) :
  GET_VERSION = "https://dev.horizon-sdv.scpmtk.com/mtk-connect/api/v1/config/version"
  CREATE_KEY = f"https://dev.horizon-sdv.scpmtk.com/mtk-connect/api/v1/users/{USER_ID}/keys"

# New key settings: name, expiration date.
# Current settings: name is empty, expiration date is set to 1 month after creation date (UTC+00:00 Timezone)
KEY_EXPIRATION_DATE = datetime.datetime.now(tz=datetime.timezone.utc) + relativedelta(months=1)
REQUEST_BODY = {
  "name": "",
  "expiryTime": f"{KEY_EXPIRATION_DATE.strftime("%Y-%m-%dT%H:%M:%SZ")}"
}

def connect_to_api(operation=API_REQUEST_OPT.GET_VERSION, request_body=None):
  
  try:
    if operation is API_REQUEST_OPT.GET_VERSION:
      response_api = requests.get(operation.value, auth=(USERNAME, KEY))
    elif operation is API_REQUEST_OPT.CREATE_KEY:
      response_api = requests.post(operation.value, auth=(USERNAME, KEY), json=request_body)
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
connect_to_api(operation=API_REQUEST_OPT.CREATE_KEY, request_body=REQUEST_BODY)

