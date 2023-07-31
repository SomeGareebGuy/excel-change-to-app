import pandas as pd
import psycopg2
import datetime

# The destination of the file which would be automatically changed
base_file = pd.read_excel('base_file.xlsx')

# The destination of the file which would be manually changed
modified_file = pd.read_excel('modified_file.xlsx')

current_time = datetime.datetime.now()

# Connection to the ElephantSQL database
db_params = {
    'host': 'arjuna.db.elephantsql.com',
    'port': 'port',
    'database': 'database',
    'user': 'user',
    'password': 'pswrd'
}

# Configuring the connection
connection = psycopg2.connect(
    host=db_params['host'],
    port=db_params['port'],
    database=db_params['database'],
    user=db_params['user'],
    password=db_params['password']
)
cursor = connection.cursor()

# cursor.execute("CREATE TABLE database (ProductName varchar(50), UnitChange int, NewUnit int, PriceChange int,"
#               " NewPrice int, Time varchar(27), Type varchar(3))")
# connection.commit()


# Calculating the starting line and ending line of the Excel file
length = len(modified_file.index)
startingLine = 0
endingLine = 0
base_file.fillna('', inplace=True)

# Calculating the starting line of the Excel file
for i in range(0, length):
    if modified_file.at[i, "Unnamed: 0"] == "SL NO":
        startingLine = i

# Calculating the ending line of the Excel file
for i in range(startingLine + 1, length):
    if modified_file.at[i, "Unnamed: 0"] == "NaN":
        endingLine = i
    else:
        endingLine = (length - 1)

a = startingLine + 1
b = endingLine + 1

for i in range(a, b):
    name = modified_file.at[i, 'Unnamed: 1']
    unit = modified_file.at[i, 'Unnamed: 3']
    price = modified_file.at[i, 'Unnamed: 2']

    match = base_file["Unnamed: 1"].str.contains(name, case=False)

    if any(match):
        base_unit = base_file.at[match.idxmax(), 'Unnamed: 3']
        base_price = base_file.at[match.idxmax(), 'Unnamed: 2']

        unit_change = int(unit) - int(base_unit)
        price_change = int(price) - int(base_price)

        if base_unit != unit:
            if base_price != price:
                print("Product Name: {}, Unit Change: {}, Price Change: {}".format(name, unit_change, price_change))
                cursor.execute(
                    "INSERT INTO database (ProductName, UnitChange, NewUnit, PriceChange, NewPrice, Type, Time) "
                    "VALUES (%s, %s, %s, %s, %s, 'PAU', %s)",
                    (name, unit_change, unit, price_change, price, current_time)
                )
                connection.commit()
            else:
                print("Product Name: {}, Unit Change: {}".format(name, unit_change))
                cursor.execute(
                    "INSERT INTO database (ProductName, UnitChange, NewUnit, PriceChange, NewPrice, Type, Time) "
                    "VALUES (%s, %s, %s, 0, 0, 'NAU', %s)",
                    (name, unit_change, unit, current_time)
                )
                connection.commit()
        elif base_price != price:
            print("Product Name: {}, Price Change: {}".format(name, price_change))
            cursor.execute(
                "INSERT INTO database (ProductName, UnitChange, NewUnit, PriceChange, NewPrice, Type, Time) "
                "VALUES (%s, 0, 0, %s, %s, 'PAN', %s)",
                (name, price_change, price, current_time)
            )
            connection.commit()
    else:
        print("\033[1mNew Product\033[0m Product Name: {}, Unit: {}, Price: {}".format(name, unit, price))
        cursor.execute(
            "INSERT INTO database (ProductName, UnitChange, NewUnit, PriceChange, NewPrice, Type, Time) "
            "VALUES (%s, 0, %s, 0, %s, 'NEW', %s)",
            (name, unit, price, current_time)
        )
        connection.commit()

cursor.close()
connection.close()

input()

modified_file.to_excel('base_file.xlsx', index=False)

print("\033[1;32mComplete")

input()
