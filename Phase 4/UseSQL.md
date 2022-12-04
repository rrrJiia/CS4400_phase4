```
# https://github.com/mkleehammer/pyodbc/wiki/Cursor

# update insert
def operate(sql):
    conn = "mysql+pymysql://root:@localhost/travel_reservation_service"
    engine = create_engine(conn, echo=True)
    connection = engine.raw_connection()
    cursor = connection.cursor()

    try:
        cursor.execute(sql)
        cursor.close()
        connection.commit()
    except Exception as e:
        print(e)
        cursor.close()
        # Rollback in case there is any error
        connection.rollback()
    connection.close()

# select
def select(sql):
    conn = "mysql+pymysql://root:@localhost/travel_reservation_service"
    engine = create_engine(conn, echo=True)
    connection = engine.raw_connection()
    cursor = connection.cursor()
    results = None
    try:
        cursor.execute(sql)
        results = cursor.fetchall()
        cursor.close()
    except Exception as e:
        print(e)
        cursor.close()
    connection.close()
    return results

# call proc
def callproc(sql, args=[]):
    conn = "mysql+pymysql://root:@localhost/travel_reservation_service"
    engine = create_engine(conn, echo=True)
    connection = engine.raw_connection()
    cursor = connection.cursor()
    results = None
    try:
        cursor.callproc(sql, args)
#         for re in cursor.stored_results():
#             results=re.fetchall()
        results = cursor.fetchall()
        cursor.close()
        connection.commit()
    except Exception as e:
        print(e)
        cursor.close()
        # Rollback in case there is any error
        connection.rollback()
    connection.close()
    return results
```
How to use
```
operate('''insert into Owners_Rate_Customers values ('cbing10@gmail.com', 'lbryan@gmail.com', 10);''')
select('''select * from Owners_Rate_Customers;''')
callproc('test1', [])
```
