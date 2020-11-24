import pymysql
import json

# Configuration value
endpoint = 'myrdstest.czugo6dcgiaj.eu-west-1.rds.amazonaws.com'
username = 'admin'
password = 'admin1234'
database_name = 'test_db'

# connection
connection = pymysql.connect(endpoint, user=username, passwd=password, db=database_name)


def lambda_handler(event, context):
    # Parse out query String paramters

    transactionName = event['queryStringParameters']['Name']

    print('Name=' + transactionName)

    cursor = connection.cursor()
    # print ("INSERT INTO Test (name) VALUES ({0})" format(transactionName))
    commit = 'commit'
    query = 'INSERT INTO Test (name) VALUES (\'' + transactionName + '\')'
    print(query)
    cursor.execute(query)
    cursor.execute(commit)

    # Construct the body of the response object
    transactionResponse = {}
    transactionResponse['message'] = 'Post: Data inserted successfully'

    # Construct HTTP response object
    responseObject = {}
    responseObject['statusCode'] = 200
    responseObject['headers'] = {}
    responseObject['headers']['Content-Type'] = 'application/json'
    responseObject['body'] = json.dumps(transactionResponse)

    # Return the response Object
    return responseObject


connection.close





