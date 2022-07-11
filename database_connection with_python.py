# These libraries are pre-installed in SN Labs. If running in another environment please uncomment lines below to install them:
# pip install --force-reinstall ibm_db==3.1.1 ibm_db_sa==0.3.3
# Ensure we don't load_ext with sqlalchemy>=1.4 (incompadible)
# pip uninstall sqlalchemy==1.4 -y && pip install sqlalchemy==1.3.24
# !pip install ipython-sql

import ibm_db
import ibm_db_dbi
import pandas

# Replace the placeholder values with your actual Db2 hostname, username, and password:
# e.g.: "54a2f15b-5c0f-46df-8954-7e38e612c2bd.c1ogj3sd0tgtu0lqde00.databases.appdomain.cloud"
dsn_hostname = "824dfd4d-99de-440d-9991-629c01b3832d.bs2io90l08kqb1od8lcg.databases.appdomain.cloud"
dsn_uid = "bjy32482"  # e.g. "abc12345"
dsn_pwd = "Ar4LSFWbBnL8icQ8"  # e.g. "7dBZ3wWt9XN6$o0J"

dsn_driver = "{IBM DB2 ODBC DRIVER}"
dsn_database = "BLUDB"  # e.g. "BLUDB"
dsn_port = "30119"  # e.g. "32733"
dsn_protocol = "TCPIP"  # i.e. "TCPIP"
dsn_security = "SSL"  # i.e. "SSL"

# DO NOT MODIFY THIS CELL. Just RUN it with Shift + Enter
# Create the dsn connection string
dsn = (
    "DRIVER={0};"
    "DATABASE={1};"
    "HOSTNAME={2};"
    "PORT={3};"
    "PROTOCOL={4};"
    "UID={5};"
    "PWD={6};"
    "SECURITY={7};"
).format(
    dsn_driver,
    dsn_database,
    dsn_hostname,
    dsn_port,
    dsn_protocol,
    dsn_uid,
    dsn_pwd,
    dsn_security,
)

# print the connection string to check correct values are specified
# print(dsn)

# DO NOT MODIFY THIS CELL. Just RUN it with Shift + Enter
# Create database connection

try:
    conn = ibm_db.connect(dsn, "", "")
    print(
        "Connected to database: ",
        dsn_database,
        "as user: ",
        dsn_uid,
        "on host: ",
        dsn_hostname,
    )

except Exception:
    print("Unable to connect: ", ibm_db.conn_errormsg())

dropQuery = "drop  table INSTRUCTOR"

# Now execute the drop statment
# dropStmt = ibm_db.exec_immediate(conn, dropQuery)


# Construct the Create Table DDL statement - replace the ... with rest of the statement
createQuery = "create table INSTRUCTOR(id INTEGER PRIMARY KEY NOT NULL, fname VARCHAR(20) NULL,lname VARCHAR(20) NULL,city VARCHAR(20) NULL,ccode CHARACTER(2) NULL)"

# Now fill in the name of the method and execute the statement
# createStmt = ibm_db.exec_immediate(conn, createQuery)

# Construct the query - replace ... with the insert statement
insertQuery = "insert into INSTRUCTOR(id,fname,lname,city,ccode) values(1,'Rav','Ahuja','TORONTO','CA')"
insertQuery2 = "insert into INSTRUCTOR(id,fname,lname,city,ccode) values(2,'Raul','Chong','Markham','CA'),(3,'ima','Vasudevan','Chicago','US')"


# execute the insert statement
# insertStmt = ibm_db.exec_immediate(conn, insertQuery2)

# Construct the query that retrieves all rows from the INSTRUCTOR table
selectQuery = "select * from INSTRUCTOR"

# Execute the statement
selectStmt = ibm_db.exec_immediate(conn, selectQuery)

# Fetch the Dictionary (for the first row only)
ibm_db.fetch_both(selectStmt)

# Fetch the rest of the rows and print the ID and FNAME for those rows
while ibm_db.fetch_row(selectStmt) != False:
    print(
        " ID:",
        ibm_db.result(selectStmt, 0),
        " FNAME:",
        ibm_db.result(selectStmt, "FNAME"),
    )

# connection for pandas
pconn = ibm_db_dbi.Connection(conn)

# retrieve the query results into a pandas dataframe
pdf = pandas.read_sql(selectQuery, pconn)

# print just the LNAME for first row in the pandas data frame
print(pdf.LNAME[0])

# print the entire data frame
print(pdf)

ibm_db.close(conn)
