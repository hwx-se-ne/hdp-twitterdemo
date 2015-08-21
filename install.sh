#!/bin/bash

### Config:
dir="$(dirname $0)"
if ! . $dir/conf.sh
then
	echo "Unable to load configuration file $dir/conf.sh!  Aborting..."
	exit 1
fi

### Check for Kafka:
if [ ! -e /usr/hdp/current/kafka-broker ]
then
	echo Kafka is not installed.  Please install Kafka and then re-run this script.
	echo "(FIXME: Install Kafka automatically here!)"
	exit 1
fi

### Download/extract sample data:
if [ -e twitterdata/SentimentFiles.zip ]
then
	echo Twitter data already exists, so skipping download.
else
	echo Downloading Twitter sample data...
	if ! wget http://s3.amazonaws.com/hw-sandbox/tutorial13/SentimentFiles.zip -P twitterdata
	then
		echo Error downloading Twitter sample data!  Aborting...
		exit 1
	fi	
fi

if ! unzip -o twitterdata/SentimentFiles.zip -d twitterdata
then
	echo Unable to extract Twitter sample data!  Aborting...
	exit 1
fi

# OSX has a nasty habit of littering in the filesystem.  Why not at least use dotfiles, folks?
rm -rf twitterdata/__MACOSX

### Update names/paths in sample data:
ddlpath=twitterdata/SentimentFiles/upload/hive/hiveddl.sql
# Table names:
sed -i "/\//! s/tweets_raw/$tweetsraw/g" $ddlpath
sed -i "/\//! s/dictionary/$dictionary/g" $ddlpath
sed -i "/\//! s/time_zone_map/$timezone/g" $ddlpath
sed -i "/\//! s/tweets_simple/$tweetssimple/g" $ddlpath
sed -i "/\//! s/tweets_clean/$tweetsclean/g" $ddlpath
sed -i "/\//! s/tweets_bi/$tweetsbi/g" $ddlpath
sed -i "/\//! s/twitter_3grams/$twitter3grams/g" $ddlpath
# Paths:
sed -i "s@/user/hue/upload/upload/@$datapath/@g" $ddlpath
# Fix for the original script using reserved keywords as column names
sed -i 's/user/`user`/g' $ddlpath
sed -i 's/`user`_/user_/g' $ddlpath
# Fix for outdated/incompatible JSON SerDe
sed -i '1d' $ddlpath # just remove the old 'ADD' line for the SerDe packaged with the data
sed -i 's/org.openx.data.jsonserde.JsonSerDe/org.apache.hive.hcatalog.data.JsonSerDe/g' $ddlpath
# Fix for typo in DDL script
sed -i 's/RCFILESE/RCFILE/gI' $ddlpath
# Fix for wrong table name in DDL script
sed -i 's/FROM tweets group/FROM tweets_raw group/g' $ddlpath

### Fix sample data:
# The sample data is encoded in ISO-8859-1 (Latin 1) but JSON "SHALL" be UTF-8.
# The JSON SerDe barfs on unicode in Latin 1, so we need to convert to UTF-8.
tpath=twitterdata/SentimentFiles/upload/data/tweets_raw
for i in $tpath/*gz
do
	gzip -d $i
	uncompressed=$(echo $i | sed 's/.gz//')
	iconv -sc -f iso-8859-1 -t utf8 $uncompressed > $uncompressed.filtered
	rm $uncompressed
	mv $uncompressed.filtered $uncompressed
	gzip $uncompressed
done

### Upload sample data:
HADOOP_USER_NAME=$hadoopuser hdfs dfs -mkdir -p /twitterdemo
if [ $? -ne 0 ]
then
	echo Error creating /twitterdemo directory in HDFS!  Aborting...
	exit 1
fi

HADOOP_USER_NAME=$hadoopuser hadoop fs -put -f twitterdata/SentimentFiles/upload/data twitterdata/SentimentFiles/upload/hive $datapath
if [ $? -ne 0 ]
then
	echo Error uploading Twitter sample data!  Aborting...
	exit 1
fi

### Run the Hive script
if ! hive -f $ddlpath
then
	echo Error running Hive DDL script!  Aborting...
	exit 1
fi