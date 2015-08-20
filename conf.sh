#!/bin/bash

#####
# Configuration values for Twitter demo
#####

# Username the data will be stored under in HDFS:
hadoopuser=admin

# Where the sample data will land in HDFS:
datapath=/twitterdemo

# Table names:
tweetsraw=tweets_raw
dictionary=dictionary
sentiment=sentiment
timezone=time_zone_map
tweetssimple=tweets_simple
tweetsclean=tweets_clean
tweetsbi=tweetsbi
twitter3grams=twitter_3grams

# JSON SerDe
jsonserde=json-serde-1.1.6-SNAPSHOT-jar-with-dependencies.jar