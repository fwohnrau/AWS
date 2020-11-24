import requests
import json
import collections

def testAPI():
    jsonfile="./input_json/selectCustomer.json"
    customerID = 23
    input={"customerID": "2379"}
    jsonparameters=json.dumps(input)
    #with open(jsonfile, "r") as read_file:
    #    parameters = json.load(read_file)
    #print(jsonparameters)
    url1="https://tr2dcewd5k.execute-api.eu-west-1.amazonaws.com/dev/Customer"
    url1="https://hviyvxjgci.execute-api.eu-west-1.amazonaws.com/Dev/rsddb"
    url1="https://nq5onw3col.execute-api.eu-west-1.amazonaws.com/DEV/rsdapi"
    url1="https://z8r1sym8gf.execute-api.eu-west-1.amazonaws.com/dev/Customer"
    response1 = requests.get(url1,input)
    #response2 = requests.get(url1,input)

    print(response1.url)
    print(response1.raw)
    print(response1.status_code)
    print("Response1")
    print(response1.json())
    print("--------------------------")
    #print("Response2")
    #print(response2.json())

testAPI()