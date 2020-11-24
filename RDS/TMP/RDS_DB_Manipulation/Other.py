def example_driver_for_sqlalchemy():
    from sqlalchemy.engine import create_engine
    engine = create_engine(
        'mysql+pydataapi://',
        connect_args={
            'resource_arn': 'arn:aws:rds:us-east-1:123456789012:cluster:dummy',
            'secret_arn': 'arn:aws:secretsmanager:us-east-1:123456789012:secret:dummy',
            'database': 'test'
        }
    )
    result: ResultProxy = engine.execute("select * from pets")
    print(result.fetchall())


def writeToFile (f,st):
    f.writelines(st)
    return;

def readFromInput( fn,fw ):
    print (fn)
    fr = open(fn, 'r')
    Lines = fr.readlines()

    count = 0
    # Strips the newline character
    for line in Lines:
        print("Line{}: {}".format(count, line.strip()))
        writeToFile(fw,line.strip() + "\n")

    return;

def fileManipulation():
    file1 = open('myfileoutput.txt', 'w')
    readFromInput('myfileinput.txt',file1)
    file1.close()
    return;


   def dbQuery():

    # specify database configurations
    config = {
        'host': 'localhost',
        'port': 3306,
        'user': 'root',
        'password': 'rootpwd',
        'database': 'test_db'
        }
    db_user = config.get('user')
    db_pwd = config.get('password')
    db_host = config.get('host')
    db_port = config.get('port')
    db_name = config.get('database')
    # specify connection string
    connection_str = f'mysql+pymysql://{db_user}:{db_pwd}@{db_host}:{db_port}/{db_name}'
    query = 'Select * from Test'
    # connect to database
    engine = db.create_engine(connection_str)
    connection = engine.connect()
    results = connection.execute(query).fetchall()
    for result in results:
        print(result)

    query = 'INSERT INTO Test (name) VALUES (\'E\'),(\'F\'),(\'G\')'
    results = connection.execute(query)

    query = 'Select * from Test'
    results = connection.execute(query).fetchall()

    for result in results:
        print(result)

    # pull metadata of a table
    metadata = db.MetaData(bind=engine)
    metadata.reflect(only=['Test'])
    test_table = metadata.tables['Test']
    print (test_table)

    connection.close()
    return;

dbQuery()