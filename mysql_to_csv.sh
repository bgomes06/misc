#!/bin/bash

###### SCRIPT WHO CONVERT MYSQL DUMP TO CSV FILE
###### AUTHOR: BRUNO G. (bgomes06)
###### LAST UPDATE: 01/10/17

###### CONFIGURATIONS - ONLY CHANGE HERE VARIABLES TO BE USED IN YOUR ENVIRONMENT

DBTABLE='<full path to file.txt>'
DBNAME='<full path of mysql db>'
FILES_DEST='/var/lib/mysql-files' ## DEFAULT MYSQL FILE PATH TO AVOID "ERROR 1290" - --secure-file-priv option.

##### CLEAR TABLE FILES AND DESTINY FOLDER WITH .CSV FILES
clear_files(){
	if [ -f '$DBTABLE' ]; then
		rm -f $DBTABLE
	fi
	rm -rf $FILES_DEST/* 
}

##### GENERATE TABLES NAMES FROM DB
dump_showtable_txt(){
	mysql -h localhost -uroot -proot $DBNAME -e \
  	"SHOW TABLES;" > $DBTABLE
	sed -i '1d' $DBTABLE	##REMOVE FIRST LINE OF DB REFERENCE
}

##### DUMP OF EACH TABLE IN A .CSV FILE
dump_database_csv(){
	while read line; do
		mysql -h localhost -uroot -proot $DBNAME -e \
		"SELECT * INTO OUTFILE '$FILES_DEST/${line}.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\n' FROM ${line};"
	done < $DBTABLE 
}

##### DUMP OF EACH TABLE SCHEMA IN A .CSV FILE
dump_schema_csv(){
	while read line; do
		mysql -h localhost -uroot -proot -e \
		"DESCRIBE ${DBNAME}.${line}" > $FILES_DEST'/'$line'_schema.csv'
	done < $DBTABLE 
}

##### MOVE FILES FROM DEFAULT FOLDER TO NAMED FOLDER FOR BETTER ORGANIZATION
move_files() {
	if [ ! -d $FILES_DEST/schema ]; then
		mkdir $FILES_DEST/schema
	fi

	if [ ! -d $FILES_DEST/tabelas ]; then
		mkdir $FILES_DEST/tabelas
	fi

	mv $FILES_DEST/*_schema.csv $FILES_DEST/schema/
	mv $FILES_DEST/*.csv $FILES_DEST/tabelas/
}

##### ZIP FILES TO ROOT FOLDER
zip_files(){
	zip /root/$DBNAME'_schema.zip' $FILES_DEST/schema/*
	zip /root/$DBNAME'.zip' $FILES_DEST/tabelas/*
}

##### START HERE
##### CALL EACH FUNCTION
clear_files
dump_showtable_txt
dump_database_csv
dump_schema_csv
move_files
zip_files
