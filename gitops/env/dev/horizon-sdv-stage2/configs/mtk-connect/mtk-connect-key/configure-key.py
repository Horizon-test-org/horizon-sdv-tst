import requests
from enum import Enum

USERNAME = 
USER_ID = 
KEY = 

class API_REQUEST_OPT(Enum) :
  GET_VERSION = "https://dev.horizon-sdv.scpmtk.com/mtk-connect/api/v1/config/version"

def connect_to_api(operation=API_REQUEST_OPT.GET_VERSION, request_body=None):
  if operation is API_REQUEST_OPT.GET_VERSION:
    response_api = requests.get(operation.value, auth=(USERNAME, KEY))

  print(f"status code: {response_api.status_code}")
  print(f"response:\n{response_api.text}")
    # return response_api


print("Script start")
connect_to_api()

