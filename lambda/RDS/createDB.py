import pymysql
import json

def GetDBConnectionDetails():
    conDet = {}
    with open("./config/DBConf.json", "r") as read_file:
        parameters = json.load(read_file)
        if (parameters["SOURCE"]).lower() == "file":
            print("Source is a File")
            for param in parameters:
                conDet[param]=parameters[param]
        else:
            #Get secret name from Secret Manager
            print("Source is not a File")

    for i in conDet:
        print(i + " : " + conDet[i])
    return conDet

#def lambda_handler(event, context):
def lambda_handler():
    connectionDetails = GetDBConnectionDetails()
    connection = pymysql.connect(connectionDetails["DB-HOST"], user=connectionDetails["DB-USER"], port=int(connectionDetails["DB-PORT"]), passwd=connectionDetails["DB-USER-PWD"], db=connectionDetails["DB-NAME"])

    try:
        with connection.cursor() as cur:
            f = open(connectionDetails["SCRIPT"],'r')
            for line in f:
                print(line, end='')
                cur.execute(line)


    finally:

        connection.commit()
        connection.close()



lambda_handler()
