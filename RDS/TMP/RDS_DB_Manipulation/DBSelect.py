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
    cursor = connection.cursor()

    cursor.execute('SELECT * from Test')

    rows = cursor.fetchall()
    msg = ''
    for row in rows:
        msg = msg + row[1] + '\r\n'
        print(row)
    # print “ID:{0} with Name:{1} ” format(frow[0], row[1])

    # Construct the body of the response object
    transactionResponse = {}
    transactionResponse['message'] = msg

    # Construct HTTP response object
    responseObject = {}
    responseObject['statusCode'] = 200
    responseObject['headers'] = {}
    responseObject['headers']['Content-Type'] = 'application/json'
    responseObject['body'] = json.dumps(transactionResponse)

    # Return the response Object
    return responseObject


connection.close




