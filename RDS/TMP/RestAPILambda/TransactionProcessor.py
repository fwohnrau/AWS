import json

print('loading function')


def lambda_handler(event, context):
    # Parse out query String paramters
    print(event)
    transactionID = event['queryStringParameters']['id']
    transactionType = event['queryStringParameters']['type']
    transactionAmount = event['queryStringParameters']['amount']

    print('TransactionID=' + transactionID)
    print('TransactionType=' + transactionType)
    print('TransactionAmount=' + transactionAmount)

    # Construct the body of the response object
    transactionResponse = {}
    transactionResponse['transactionid'] = transactionID
    transactionResponse['type'] = transactionType
    transactionResponse['amount'] = transactionAmount
    transactionResponse['message'] = 'Get: Hello from lamdba'

    # Construct HTTP response object
    responseObject = {}
    responseObject['statusCode'] = 200
    responseObject['headers'] = {}
    responseObject['headers']['Content-Type'] = 'application/json'
    responseObject['body'] = json.dumps(transactionResponse)

    # Return the response Object
    return responseObject


print('End loading function')


