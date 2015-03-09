#!/bin/bash

function as_absolute(){
	echo `cd $1; pwd`
}

function export_rdf(){
	command=$1	
	from=$2
	to=$3

	echo "exporting $from as $to"
	java -Xms256m -Xmx4g -cp .:'ontology_summarization.jar' it.unimib.disco.summarization.output.$command $from $to
	echo "done"
}

set -e
relative_path=`dirname $0`
root=`cd $relative_path;pwd`
project=$root/../summarization

mkdir -p $2

input_directory=$(as_absolute $1)/patterns
output_directory=$(as_absolute $2)
graph=$3

cd $root
./build-java-summarization-module.sh

cd $project
export_rdf WriteConceptsToRDF $input_directory/obj-patterns/countConcepts.txt $output_directory/count-concepts.nt 
export_rdf WriteConceptsToRDF $input_directory/dt-patterns/countDataType.txt $output_directory/count-datatype.nt 
export_rdf WritePropertiesToRDF $input_directory/obj-patterns/countProp.txt $output_directory/count-properties.nt 
export_rdf WritePropertiesToRDF $input_directory/dt-patterns/countDTProp.txt $output_directory/count-datatype-properties.nt 
export_rdf WriteAKPToRDF $input_directory/obj-patterns/relationCount.txt $output_directory/relation-count.nt
export_rdf WriteAKPToRDF $input_directory/dt-patterns/relationDTCount.txt $output_directory/relation-datatype-count.nt

export_rdf WritePropertiesOtherStatToRDF $input_directory/obj-patterns/countSUBJ.txt $output_directory/count-subjects.nt 
export_rdf WritePropertiesOtherStatToRDF $input_directory/obj-patterns/countOBJ.txt $output_directory/count-objects.nt 
export_rdf WritePropertiesOtherStatToRDF $input_directory/dt-patterns/countDTSUBJ.txt $output_directory/count-datatype-subjects.nt 
export_rdf WritePropertiesOtherStatToRDF $input_directory/dt-patterns/countDTOBJ.txt $output_directory/count-datatype-objects.nt 

export_rdf WriteSubjAAKPToRDF $input_directory/obj-patterns/countClassSUBJ.txt $output_directory/count-class-subject.nt 
export_rdf WriteObjAAKPToRDF $input_directory/obj-patterns/countClassOBJ.txt $output_directory/count-class-object.nt 
export_rdf WriteSubjAAKPToRDF $input_directory/dt-patterns/countClassDTSUBJ.txt $output_directory/count-datatype-class-subject.nt 
 
cd $root

echo "indexing the result of the analysis in ${output_directory} into virtuoso endpoint"
./isql.sh "delete from DB.DBA.load_list;ld_dir ('${output_directory}', '*.nt', '${graph}');rdf_loader_run();"
echo "done"

rm -r $output_directory