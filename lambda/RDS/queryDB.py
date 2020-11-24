import pymysql
import requests
import json
import collections
import logging



def GetDBConnectionDetails(json_config):
    conDet = {}
    with open(json_config, "r") as read_file:
        parameters = json.load(read_file)
        if (parameters["SOURCE"]).lower() == "file":
            msg="Source is a File"
            for param in parameters:
                conDet[param]=parameters[param]
        else:
            #Get secret name from Secret Manager
            msg="Source is not a File"

    #print(msg)
    for i in conDet:
        msg=i + " : " + conDet[i]
        #print(msg)
    return conDet


def getSQLParameters(action,json_input):
    sqlqueries=[]

            #print(queryfields)
            #print(queryvalues)
            if action == "POST"
                k = query["Key"]
                pv = query["Value"]
                sql = "UPDATE INTO {} ({}) VALUES ({});"
                sql = sql.format(table, pk, pv)


            if action == "PUT":
                with open(json_input, "r") as read_file:
                    query = json.load(read_file)
                    table = query["Table"]
                    # print(table)
                    # print(query["Fields"])

                    for index in range(0, len(query["Fields"])):
                        jsonfields = query["Fields"][index]
                        queryfields = ""
                        queryvalues = ""
                        count = 0
                        s = len(jsonfields)
                        # print(s)
                        for f, v in jsonfields.items():
                            # print(f + ':' + v)
                            if count == 0 or count == s:
                                delim = ""
                            else:
                                delim = ", "

                            count = count + 1
                            queryfields = queryfields + delim + f
                            queryvalues = queryvalues + delim + '"' + v + '"'


                        sql = "INSERT INTO {} ({}) VALUES ({});"
                        sql = sql.format(table,queryfields,queryvalues)
                        sqlqueries.append(sql)

            if action == "DELETE"
                pk = query["Key"]
                pv = query["Value"]
                sql = "DELTE from {} WHERE {} LIKE '{}';"
                sql = sql.format(table, pk, pv)


            #print(sql)
            #print("----------")

    return sqlqueries

def itemExists(con,t,pk,pkv):
    jsonconfig = "./config/db.json"

    #connectionDetails = GetDBConnectionDetails(jsonconfig)
    #connection = pymysql.connect(connectionDetails["DB-HOST"], user=connectionDetails["DB-USER"],
    #                             port=int(connectionDetails["DB-PORT"]), passwd=connectionDetails["DB-USER-PWD"],
    #                             db=connectionDetails["DB-NAME"])

    try:
        with con.cursor() as cursor:
            sql = "Select count(*) from {} where {} like '{}'"
            sql = sql.format(t, pk, pkv)
            #print(sql)
            cursor.execute(sql)
            rows = cursor.fetchall()
            #print(len(rows))
            #print(rows)
            if int(rows[0][0]) == 1:
                msg="Customer with {}:{} already exists"
            else:
                msg = "Customer with {}:{} does not exists"
            msg = msg.format(pk, pkv)
            print(msg)


    finally:
        con.close()

    return msg

def selectItems(con):

    try:
        with con.cursor() as cursor:
            sql="Select * from Details"
            print(sql)
            cursor.execute(sql)
            rows = cursor.fetchall()
            objects_list = []
            for row in rows:
                d = collections.OrderedDict()
                d["id"] = row[0]
                d["lastname"] = row[1]
                d["firstname"] = row[2]
                d["email"] = row[3]
                objects_list.append(d)
            msg = json.dumps(objects_list)
            print(j)

    finally:
        con.close()

    return msg

def createItem(con,jsonfile):

    sqlqueries=getSQLParameters(jsonfile)
    #print(len(sqlqueries))

    try:
        with connection.cursor() as cursor:
            for sql in sqlqueries:
                print(sql)
                cursor.execute(sql)
                msg="Item added"


    finally:
        connection.commit()
        connection.close()

    return msg


#def lambda_handler(event, context):
def lambda_handler():
    jsonconfig = "./config/db.json"
    jsoninsert = "./input_json/insert.json"
    jsoninsert = "./input_json/delete.json"
    jsonupdate = "./input_json/update.json"
    connectionDetails = GetDBConnectionDetails(jsonconfig)
    connection = pymysql.connect(connectionDetails["DB-HOST"], user=connectionDetails["DB-USER"],
                                 port=int(connectionDetails["DB-PORT"]), passwd=connectionDetails["DB-USER-PWD"],
                                 db=connectionDetails["DB-NAME"])

    if event['httpMethod']==GET:
        print ("GET")
        msg=selectItems(connection)

    if event['httpMethod']==POST:
        print ("PUT")
        msg=itemCreation(connection,jsoninsert)

    if event['httpMethod']==PUT:
        print ("POST")
        #msg=itemUpdate(connetion,jsonupdate)

    if event['httpMethod']==DELETE:
        print ("DELETE")
        # msg=itemDelete(connetion,jsondelete)

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
    print(responseObject)
    return responseObject



def test():

    jsonconfig = "./config/db.json"
    jsoninsert = "./input_json/insert.json"
    jsondelete = "./input_json/delete.json"
    connectionDetails = GetDBConnectionDetails(jsonconfig)
    connection = pymysql.connect(connectionDetails["DB-HOST"], user=connectionDetails["DB-USER"],
                                     port=int(connectionDetails["DB-PORT"]), passwd=connectionDetails["DB-USER-PWD"],
                                     db=connectionDetails["DB-NAME"])

    msg=itemExists(connection,"Details","email","wwohnrau@gmail.com")
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
    print(responseObject)

test()