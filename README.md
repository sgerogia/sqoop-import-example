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

### Data type mapping

Use this section if you need to process a specific DB column which is not recognized by default. 

You can add multiple DB column names as a comma-separated list, in the form `columnName=DateType`.

The possible datatypes you can use are:

* `Integer`
* `Long`
* `Float`
* `Double`
* `Boolean`
* `String`
* `java.sql.Date`
* `java.sql.Time`
* `java.sql.Timestamp`
* `java.math.BigDecimal`
* `com.cloudera.sqoop.lib.ClobRef` (for `CLOB` DB columns, will become a Hive `BINARY` column)
* `com.cloudera.sqoop.lib.BlobRef` (for `CLOB` DB columns, will become a Hive `BINARY` column)

**Important:** Only use this functionality if a column is causing issues or you want to optimize some downstream process.
 In most cases, Hive's default translation is the optimal.

### LOB 
 
Large objects are always imported as non-materialized objects, i.e. the data is stored in a separate sub-folder.
 
See 
 
* Hive's [Large Objects][5] documentation 
* Detailed explanation in [Hadoop: The Definitive Guide][6]

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


## Possible improvements 

You may want to consider the following as possible improvements (or as exercise), depending on your needs

* adding support for multiple mapped columns
* nohup-ing the execution of the actual import to parallelize the import in the case of many tables
 


   [1]: ./scripts/tables.txt
   [2]: ./scripts/sqoop-import.sh
   [3]: ./scripts/import.sh
   [4]: ./docs/res/linefeed.png?raw
   [5]: https://sqoop.apache.org/docs/1.4.2/SqoopUserGuide.html#_large_objects
   [6]: https://books.google.co.uk/books?id=MhqkBwAAQBAJ&pg=PA417&lpg=PA417&dq=hive++externalLob&source=bl&ots=VzIQN09WY9&sig=M_tZ29dRn4QU4slJPCxKPN6Qal0&hl=en&sa=X&ved=0CD4Q6AEwBGoVChMI35_TvoyDxwIVRo4sCh2MQwLY#v=onepage&q=hive%20%20externalLob&f=false