import requests
from enum import Enum

USERNAME = 
USER_ID = 
KEY = 

class API_REQUEST_OPT(Enum) :
  GET_VERSION = "https://dev.horizon-sdv.scpmtk.com/mtk-connect/api/v1/config/version"
  CREATE_KEY = f"https://dev.horizon-sdv.scpmtk.com/mtk-connect/api/v1/users/{USER_ID}/keys"

REQUEST_BODY = {
  "name": "jenkins",
  "expiryTime": "2024-12-17T11:59:42.367Z",
}

def connect_to_api(operation=API_REQUEST_OPT.GET_VERSION, request_body=None):
  if operation is API_REQUEST_OPT.GET_VERSION:
    response_api = requests.get(operation.value, auth=(USERNAME, KEY))
  elif operation is API_REQUEST_OPT.CREATE_KEY:
    response_api = requests.post(operation.value, auth=(USERNAME, KEY), data=request_body)

  print(f"status code: {response_api.status_code}")
  print(f"response:\n{response_api.text}")
    # return response_api


print("Script start")
print("Get version of MTK Connect")
connect_to_api()
print(f"Create key for user id {USER_ID}")
connect_to_api(operation=API_REQUEST_OPT.CREATE_KEY, request_body=REQUEST_BODY)

