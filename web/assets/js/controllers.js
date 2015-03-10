var summary = angular.module('schemasummaries', []);

summary.controller('Summarization', function ($scope, $http, $location) {
	
	$scope.loadTopFrequentPatterns = function(){
		
		new Sparql($http, $location)
			.query('select ?subject ?predicate ?object ?frequency ' + 
					'where { '+
			         	'?pattern a ss:AbstractKnowledgePattern . ' +
			         	'?pattern rdf:subject ?subject . ' +
			         	'?pattern rdf:predicate ?predicate . ' + 
			         	'?pattern rdf:object ?object . ' +
			         	'?pattern ss:has_frequency ?frequency . ' +
		         	'} ' +
		         	'order by desc(?frequency) ' +
		         	'limit 10')
         	.onGraph($scope.selected_graph)
         	.accumulate(function(results){
				$scope.summaries=results;
				$scope.graph_was_selected=true;
			});
	};
	
	$scope.filterPatterns = function(){
		
		var subject = valueOrDefault($scope.subject, '?subject');
		var predicate = valueOrDefault($scope.predicate, '?predicate');
		var object = valueOrDefault($scope.object, '?object');
		
		new Sparql($http, $location)
			.query('select ' + subject + 'as ?subject ' + predicate + ' as ?predicate ' + object + ' as ?object ?frequency ' +
					'where { ' +
						'?pattern a ss:AbstractKnowledgePattern . ' +
						'?pattern rdf:subject ' + subject + ' . ' +
						'?pattern rdf:predicate ' + predicate + ' . ' + 
			         	'?pattern rdf:object ' + object + ' . ' +
			         	'?pattern ss:has_frequency ?frequency . ' +
					'} ' +
					'order by desc(?frequency) ')
			.onGraph($scope.selected_graph)
			.accumulate(function(results){
				$scope.summaries=results;
			});;
	}
	
	$scope.selected_graph='Select a dataset';
	
	new Sparql($http, $location)
			.query("select distinct ?uri where {GRAPH ?uri {?s ?p ?o} . FILTER regex(?uri, 'schemasummaries')}")
			.accumulate(function(results){
				$scope.graphs=results;
			});
});

valueOrDefault = function(value, default_value){
	var value_to_return = default_value;
	if(value) value_to_return = '<' + value + '>';
	return value_to_return;
}

Sparql = function(http_service, location_service){
	
	var http = http_service;
	var location = location_service;
	var graph = "";
	var query;
	
	this.onGraph = function(target_graph){
		graph = target_graph;
		return this;
	};
	
	this.query = function(query_to_execute){
		query = query_to_execute;
		return this;
	};
	
	this.accumulate = function(onSuccess){
		http.get('http://' + location.host() + ':8890/sparql', {
	        method: 'GET',
	        params: {
	            query: 'prefix rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#> ' +
		        	   'prefix ss:   <http://schemasummaries.org/ontology/> '+
	         	       query,
	            'default-graph-uri' : graph,
	            format: 'json'
	        }
	    }).success(function(res){
	    	onSuccess(res.results.bindings);
	    });
	};
};