# Using MSSQL with Python

For some reason, python and MSSQL just don't like each other and if you use python on a mac, they outright hate each other.

This is my attempt at configuring my mac and windows in a single method to be able to connect to mssql from python.

First, I am using a SQL Server Authentication login on the MSSQL server. I am not using a Windows Authentication login. It is simple to use Windows Authentication when running python on a windows box, but it isn't so simple when running it on mac.

I learned 90% of this from here: [Mac setup to connect to MSSQL](https://github.com/lionheart/django-pyodbc/wiki/Mac-setup-to-connect-to-a-MS-SQL-Server)

I need to be able to connect to mssql using PYODBC & SQLAlchemy. This required a bit of exploration because the above link doesn't teach how to do to configure for SQLAlchemy.

These 2 files can be run on either windows or mac
* DB.ipynb is the jupyter notebook with my python code
* config.ini is a Config file with the structure of the connection strings and other identifying information

These files are specifically for mac:
* freetds.conf is an example of my FreeTDS config
* odbc.ini is an example of odbc config
* odbcinst.ini is an example of my odbcinst config

On windows, just create a 32bit or 64bit ODBC connection with the same settings/names you use in odbc.ini
Example image of ODBC:
* WindowsODBC.jpg
