#!/bin/bash

function as_absolute()
{
	echo `cd $1; pwd`
}

function run(){
	echo "Exporting $@"
	java -Xms256m -Xmx16g -cp .:'summarization.jar' it.unimib.disco.summarization.export.$@
	echo "Done"
}

set -e
relative_path=`dirname $0`
current_directory=$(as_absolute $relative_path)
cd $current_directory

echo
echo "Indexing the produced summary"

solr_port=8891
dataset=$1
payleveldomain=$2

cd ../summarization

run InternalExternalConcept ../data/summaries/$dataset/patterns/count-concepts.txt $dataset $payleveldomain
run InternalExternalConcept ../data/summaries/$dataset/patterns/count-datatype.txt $dataset $payleveldomain
run InternalExternalDatatypeProperty ../data/summaries/$dataset/patterns/count-datatype-properties.txt $dataset $payleveldomain
run InternalExternalObjectProperty ../data/summaries/$dataset/patterns/count-object-properties.txt $dataset $payleveldomain
run InternalExternalDatatypeAkp ../data/summaries/$dataset/patterns/datatype-akp.txt $dataset $payleveldomain
run InternalExternalObjectAkp ../data/summaries/$dataset/patterns/object-akp.txt $dataset $payleveldomain
run DeleteAllDocumentsFromIndex localhost $solr_port $dataset

sleep 1

run IndexSingle localhost $solr_port ../data/summaries/$dataset/patterns/count-concepts-new.txt $dataset concept
run IndexSingle localhost $solr_port ../data/summaries/$dataset/patterns/count-datatype-new.txt $dataset datatype
run IndexSingle localhost $solr_port ../data/summaries/$dataset/patterns/count-datatype-properties-new.txt $dataset datatypeProperty
run IndexSingle localhost $solr_port ../data/summaries/$dataset/patterns/count-object-properties-new.txt $dataset objectProperty
run IndexAkps localhost $solr_port ../data/summaries/$dataset/patterns/datatype-akp-new.txt $dataset datatypeAkp
run IndexAkps localhost $solr_port ../data/summaries/$dataset/patterns/object-akp-new.txt $dataset objectAkp

cd ../pipeline
