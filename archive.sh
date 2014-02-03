#!/bin/sh
#Archive all folders and sync with amazon Glacier

DIR=`dirname $0`
$DIR/parameters.sh

#cycle by every folder in SOURCE_FOLDER
for i in `find $SOURCE_FOLDER -maxdepth 1 -mindepth 1 -type d -exec basename {} \;`
do
	echo "Working with directory "$i
	
	#check exits subfolder in HLINKS_FOLDER
	if [ ! -d $HLINKS_FOLDER$i ]; then
		echo "directory "$i" not found. Creating..."
		
		mkdir $HLINKS_FOLDER$i 
	fi
	
	#compare directories for new files
	find $SOURCE_FOLDER$i -type f -exec basename {} \; | sort > /tmp/source_files  
	find $HLINKS_FOLDER -type f -exec basename {} \; | sort > /tmp/arc_files
	
	#find new files in source_files
	comm -23 /tmp/source_files /tmp/arc_files > /tmp/archive_files
	
	if [ -s /tmp/archive_files ]; then
			#generate archive name
			ARC_NAME=/tmp/$i"_"`date +'%d%m%Y%H%M'`".tar.gz"
	
			cat /tmp/archive_files
	
			echo "Creating archive - "$ARC_NAME
	
			#change directory to source and archive only new files		
			cd $SOURCE_FOLDER$i && tar cvfz $ARC_NAME --files-from /tmp/archive_files
	      
			#copy hard links to HLINKS_FOLDER
			cp -al $SOURCE_FOLDER$i $HLINKS_FOLDER
	else
			echo "No new files"
	fi		
done