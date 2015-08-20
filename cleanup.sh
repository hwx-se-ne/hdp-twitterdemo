#!/bin/bash

### Config:
dir="$(dirname $0)"
if ! . $dir/conf.sh
then
	echo "Unable to load configuration file $dir/conf.sh!  Aborting..."
	exit 1
fi

paths=( "$datapath" )
tables=( "$tweetsbi" "$sentiment" "$tweetsraw" "$dictionary" "$timezone" "$twitter3grams" )
views=( "l1" "l2" "l3" "$tweetsclean" "$tweetssimple" )

echo ; echo ; echo
echo You are about to remove any existing log data that has been generated.
echo This will remove data from HDFS and the host filesystem!
echo
echo Actions that will be taken:
echo "   Delete all data from HDFS paths:"
for h in "${paths[@]}" ; do echo "     $h" ; done
echo
echo "   Drop Hive views:"
for t in "${views[@]}" ; do echo "      $t" ; done
echo
echo "   Drop Hive tables:"
for t in "${tables[@]}" ; do echo "      $t" ; done
echo ; echo
echo THIS CANNOT BE UNDONE.
echo ; echo
read -p "Continue? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	# Drop hive views
	for t in "${views[@]}"
	do
		if ! hive -e "DROP VIEW $t;" ; then echo "Unable to drop view $t!  Aborting..." && exit 1 ; fi
	done

	# Drop hive tables
	for t in "${tables[@]}"
	do
		if ! hive -e "DROP TABLE $t;" ; then echo "Unable to drop table $t!  Aborting..." && exit 1 ; fi
	done
	# Clean up HDFS
	for h in "${paths[@]}"
	do
		if ! HADOOP_USER_NAME=$hadoopuser hdfs dfs -rm -r $h/*
		then
			echo "NOTICE: Unable to remove files from HDFS path $h!"
		fi
	done
else
	echo "Aborting cleanup."
	exit 0
fi

echo ; echo ; echo
echo Cleanup complete!  You can now run \"install.sh\" to re-deploy the demo.
echo To permanently remove the sample data, run \"rm -rf twitterdata\".
