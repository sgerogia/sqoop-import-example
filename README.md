# Raw table Sqoop import script

This module contains an example Sqoop import script for any number of tables.

If you are new to this area, it could be useful as a starting point.
Feel free to use it in your own projects.

## How it works

* The list of tables to be imported is defined in [tables.txt][1].
The file's columns are self-explanatory. 
Commented and blank lines are ignored.
* The script assumes that you have a HiveServer2 available to connect to.
* It attempts to delete the previous copy of the data from HDFS
* It lets Sqoop take care of import to Hive 
* Tables are processed one at a time and any errors are printed on the console.

## Configuration 

Before you can use the script on your environment, make sure that 

* you review and set the right environment values in [sqoop-import.sh][2]
* you use the right JDBC URL in [import.sh][3] (the example one is for SQL Server)
* you modify the Hive table paths and types [import.sh][3] 


## Usage

* Copy or checkout the project in your Sqoop client machine 
* `cd /path/to/sqoop-import/scripts`
* Run `./sqoop-import.sh`; there should be no errors on the output

## Making changes
 
When working with the scripts on Windows or Mac, make sure that your editor does NOT change the line ending of the Bash scripts.
It should be "Linux line feed".

For example, in IntelliJ the correct setting is highlighted below.
 
 ![IntelliJ line-feed setting][4]




   [1]: ./scripts/tables.txt
   [2]: ./scripts/sqoop-import.sh
   [3]: ./scripts/import.sh
   [4]: ./docs/res/linefeed.png?raw