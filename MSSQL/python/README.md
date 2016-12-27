# Setup Mac & Windows to connect to MSSQL with Pyodbc and SQLAlchemy

######Credit for some of this readme goes to [lionheart/django-pyodbc wiki][0]


For some reason, python and MSSQL just don't like each other and if you use python on a mac, they outright hate each other.

This is my attempt at configuring my mac and windows in a single method to be able to connect to mssql from python using both pyodbc and sqlalchemy.

I am using a SQL Server Authentication login on the MSSQL server. I am not using Windows Authentication login. It is simple to use Windows Authentication when running python on a windows box, but it isn't so simple when running it on mac.

* Login Name = login
* Password = password
* DSN = Prod
   
This guide is for connecting to MSSQL using pyodbc & sqlalchemy.
   `pip install pyodbc sqlalchemy`
   

## Mac Configuration

 1. Install **Homebrew** from [here][2] - this is a package manager for Mac OSX.  The article shows how to use another package manager 'MacPorts'.  For my instructions, they're with homebrew.  Basically homebrew has a folder 'cellar' that holds different versions of packages.  Instead of modifying your normal files, it instead points to these homebrew packages.

 2. Install **FreeTDS**:
 	
 `brew install freetds --with-unixodbc`
 
 FreeTDS is the driver that sits between the Mac ODBC and MS SQL Server

 3. Edit **freetds.conf** configuration file:

 Homebrew install placed my file in `/usr/local/etc`
 
        [global]
         tds version = auto
	     # Command and connection timeouts
         ;	timeout = 10
         ;	connect timeout = 10
	     text size = 64512

        [Prod] # name of this server
	     host = win10 # name/ip of the mssql server
	     port = 1433
	     tds version = 8.0 

 4. Verify **FreeTDS** installation and configuration
 
 `tsql -S Prod -U login -P password` 
 
 You will see a prompt like this if it worked

        locale is "en_US.UTF-8"
        locale charset is "UTF-8"
        using default charset "UTF-8"
        1>

 5. Install **unixODBC** with `brew install unixodbc`.

 6. Edit your **unixODBC config files**, which includes **odbcinst.ini** (driver configuration), and **odbc.ini** (DSN configuration file).  My files were placed in `/usr/local/etc` by the homebrew install.

 7. **odbcinst.ini**: This is the driver. I am using FreeTDS in this guide. The **Driver** & **Setup** files were placed in the location defined below by the install process for FreeTDS.

        [FreeTDS]
        Description=FreeTDS Driver for Linux & MSSQL on Win32
        Driver=/usr/local/lib/libtdsodbc.so
        Setup=/usr/local/lib/libtdsodbc.so
        UsageCount=1

 8. **odbc.ini**: This file defines the actual odbc connection. The [Prod] is the DSN name of our ODBC connection, you can name it whatever you want. **Servername** is the name of the server we defined in freetds.conf. **Driver** is the name of the driver we definded in odbcinst.ini.

        [Prod] # This is the name of my DSN
        Description         = MSSQL
        Driver              = FreeTDS
        Trace               = Yes
        TraceFile           = /tmp/sql.log
        Database            = Test
        Servername          = Prod # The name of freetds server
        UserName            = login
        Password            = password
        Port                = 1433
        Protocol            = 8.0
        ReadOnly            = No
        RowVersioning       = No
        ShowSystemTables    = No
        ShowOidColumn       = No
        FakeOidIndex        = No

 9. **Verify unixODBC** installed correctly with: `isql Prod login password`.  If you get an error that you cannot connect, then add `-v` to check what the verbose output is and fix it.  Otherwise, you should see this:

        +---------------------------------------+
        | Connected!                            |
        |                                       |
        | sql-statement                         |
        | help [tablename]                      |
        | quit                                  |
        |                                       |
        +---------------------------------------+ 


## Windows Configuration

By default, windows comes installed with ODBC. You may have to install the [SQL Server Native Client][5].  Just create a 32bit or 64bit ODBC connection with the same settings/names you used in odbc.ini. In this guide I have been using **Prod**.

Example image of ODBC:

![WindowsODBC.jpg](WindowsODBC.jpg)


## Code

```python
import pyodbc, sqlalchemy

# Test Pyodbc
conn = pyodbc.connect("DSN=Prod;UID=login;PWD=password", autocommit=True)
curs = conn.cursor()
curs.execute("SELECT @@ServerName AS ServerName, DB_NAME() AS DatabaseName")
print curs.fetchone()

# Test SQLAlchemy
meta_engine = sqlalchemy.create_engine("mssql+pyodbc://login:password@Prod")
connection = meta_engine.connect()
result = connection.execute("SELECT @@ServerName ServerName, DB_NAME() AS DatabaseName")
for row in result:
    print (row['ServerName'], row['DatabaseName'])
```


## Associated Files

The following files in this folder are some examples of config, ini, and python code.

These 2 files can be used on both windows and mac, for the purposes of this README you don't need these files.

* **DB.ipynb** is the jupyter notebook with my python code to test the connections
* **config.ini** is a config file with the the connection strings to the MSSQL server, you don't need this if you want to just create the connection strings directly in your code

These files are specifically for mac. They will be discussed later in this guide. I am including them only as

* **freetds.conf** is an example of my FreeTDS config
* **odbc.ini** is an example of odbc config
* **odbcinst.ini** is an example of my odbcinst config


You can refer to the [documentation][4] of pyodbc to get more help after this.

  [0]: https://github.com/lionheart/django-pyodbc/wiki/Mac-setup-to-connect-to-a-MS-SQL-Server
  [1]: http://www.cerebralmastication.com/2013/01/installing-debugging-odbc-on-mac-os-x/
  [2]: http://brew.sh/
  [3]: http://freetds.schemamania.org/userguide/choosingtdsprotocol.htm
  [4]: https://code.google.com/p/pyodbc/wiki/GettingStarted
  [5]: https://msdn.microsoft.com/en-us/library/ms131321.aspx
