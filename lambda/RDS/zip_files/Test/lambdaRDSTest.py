import pymysql
import json

def lambda_handler(event, context):
    print(event)
    httpMethod=event['httpMethod']
    print(httpMethod)
    print(event['queryStringParameters'])
    
    #transactionJson = event['queryStringParameters']['json']
    #print(transactionName)
    
    #for e in event:
     #   print(e)
    
    # Construct the body of the response object
    transactionResponse = {}
    #transactionResponse['message'] = event['httpMethod'] 
    if(httpMethod == "GET"):
        jsoninput=event['queryStringParameters']
        print(jsoninput)
        print(type(jsoninput))
        print(len(jsoninput))
        print("start parsing jsoninput")
        for x in jsoninput:
            print(x)
        print("End parsing jsoninput")
        transactionResponse['message'] = jsoninput['customerID']
        
    if(httpMethod == "POST"):
        body=json.dumps(event['body'])
        transactionResponse['message'] = body


    # Construct HTTP response object
    responseObject = {}
    responseObject['statusCode'] = 200
    responseObject['headers'] = {}
    responseObject['headers']['Content-Type'] = 'application/json'
    responseObject['body'] = json.dumps(transactionResponse)

    # Return the response Object
    return responseObject
    
    #return event
