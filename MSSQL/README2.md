Welcome to the django-pyodbc wiki!

Below are instructions for setting up a Mac to connect to a MS SQL Server database.

**Summary**

I'm using a Mac on Yosemite Version 10.10.1 trying to connect to a MS SQL Server database.  I searched and couldn't find an updated detailed answer so here's a writeup that is mostly from this amazing article [here][1].  I'm adding it on stackoverflow in case the link dies.  The idea is that we'll have the following layers to setup/connect.

**Layers**

 - PART 1 - pyodbc
 - PART 2 - freeTDS (can check with tsql)
 - PART 3 - unixODBC (can check with isql)
 - PART 4 - MS SQL (can check with a regular python program)

**Steps**

 1. Install **Homebrew** from [here][2] - this is a package manager for Mac OSX.  The article shows how to use another package manager 'MacPorts'.  For my instructions, they're with homebrew.  Basically homebrew has a folder 'cellar' that holds different versions of packages.  Instead of modifying your normal files, it instead points to these homebrew packages.


 2. We need to install Pyodbc:

    pip install pyodbc


 3. **Install FreeTDS** with `brew install freetds --with-unixodbc` (FreeTDS is the driver that sits between the Mac ODBC and MS SQL Server, [this][3] chart here shows which version of TDS you should be using based on your specific Microsoft Server version; e.g. tds protocol 7.2 for Microsoft SQL Server 2008).

 4. **Configure `freetds.conf`** file (The file should be in '/usr/local/etc/freetds.conf', which for Homebrew is a link to say '/usr/local/Cellar/freetds/0.91_2/etc', but yours might be somewhere different depending on version).  I edited the global and added my database info to the end (for some reason 'tds version = 7.2' would throw an error, but still work, while 8.0 just works):

        [global]
        # TDS protocol version
    	tds version = 8.0

        [MYSERVER]
	    host = MYSERVER
	    port = 1433
	    tds version = 8.0

 5. **Verify FreeTDS installed** correctly with: `tsql -S myserver -U myuser -P mypassword` (you should see a prompt like this if it worked)

        locale is "en_US.UTF-8"
        locale charset is "UTF-8"
        using default charset "UTF-8"
        1>

 6. Install **unixODBC** with `brew install unixodbc`.

 7. Setup your **unixODBC config files**, which includes **odbcinst.ini** (driver configuration), and **odbc.ini** (DSN configuration file).  By default, my files were in: `/Library/ODBC` (Note: NOT my user library aka /Users/williamliu/Library). Or they could also be in your homebrew installation directory `/usr/local/Cellar/unixodbc/<version>/etc`.

 8. Open up your '**odbcinst.ini**' file and then add the following (Note: Different if you use MacPorts.  For Homebrew, this file is a link to the homebrew version e.g. mine is in '/usr/local/Cellar/freetds/0.91_2/lib/libtdsodbc.so'):

        [FreeTDS]
        Description=FreeTDS Driver for Linux & MSSQL on Win32
        Driver=/usr/local/lib/libtdsodbc.so
        Setup=/usr/local/lib/libtdsodbc.so
        UsageCount=1

 9. Open up your '**odbc.ini**' and then add the following (this is usually along with `odbcinst.ini`:

        [MYSERVER]
        Description         = Test to SQLServer
        Driver              = FreeTDS
        Trace               = Yes
        TraceFile           = /tmp/sql.log
        Database            = MYDATABASE
        Servername          = MYSERVER
        UserName            = MYUSER
        Password            = MYPASSWORD
        Port                = 1433
        Protocol            = 8.0
        ReadOnly            = No
        RowVersioning       = No
        ShowSystemTables    = No
        ShowOidColumn       = No
        FakeOidIndex        = No

 10. **Verify unixODBC** installed correctly with: `isql MYSERVER MYUSER MYPASSWORD`.  If you get an error that you cannot connect, then add `-v` to check what the verbose output is and fix it.  Otherwise, you should see this:

        +---------------------------------------+
        | Connected!                            |
        |                                       |
        | sql-statement                         |
        | help [tablename]                      |
        | quit                                  |
        |                                       |
        +---------------------------------------+ 


 11. Now **verify pyodbc works** with a python program.  Run python in the shell or a .py file with this and you should get your query back:

        import pyodbc
        import pandas
        import pandas.io.sql as psql

        cnxn = pyodbc.connect('DSN=MYSERVER;UID=MYUSER;PWD=MYPASSWORD')
        cursor = cnxn.cursor()
        sql = ("SELECT * FROM dbo.MYDATABASE")
        df = psql.frame_query(sql, cnxn)

You can refer to the [documentation][4] of pyodbc to get more help after this.

  [1]: http://www.cerebralmastication.com/2013/01/installing-debugging-odbc-on-mac-os-x/
  [2]: http://brew.sh/
  [3]: http://freetds.schemamania.org/userguide/choosingtdsprotocol.htm
  [4]: https://code.google.com/p/pyodbc/wiki/GettingStarted