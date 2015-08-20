# hdp-twitterdemo
Twitter tutorial/demo for HDP

Prerequisites
-------------
This requires a Hortonworks sandbox image, which can be downloaded from [the Hortonworks website] (http://hortonworks.com/hdp/downloads).

Configuration
-------------
Edit the file 'conf.sh' to configure the deployed environment.  The defaults should work in a standard sandbox.

Deployment
----------
Copy the contents of this repository to the running sandbox VM and run 'install.sh'.

Running this script will download a set of sample data from Amazon S3 to the local filesystem on the sandbox.

Use
---
After installing, a number of tables will be created in Hive with data stored in JSON format in HDFS.  These tables and files represent a set of tweets from the opening of Iron Man 3, multiple views of this data, and sentiment analysis which can be viewed in an external BI tool.

See [the "How To Refine and Visualize Sentiment Data" tutorial] (http://hortonworks.com/hadoop-tutorial/how-to-refine-and-visualize-sentiment-data/) on the Hortonworks website for more information.

Cleaning up
-----------
Once you are finished, run 'cleanup.sh' to remove the data from HDFS and tables from Hive.  (This is necessary before running the scripts again as the CREATE TABLE statements will fail if the tables already exist.)

If you want to remove the downloaded sample data, run "rm -rf twitterdata" on the sandbox.  Leaving this data in place will prevent the install script from re-downloading it next time, saving some time and bandwidth.