package it.unimib.disco.summarization.systemTests;

import static org.hamcrest.Matchers.containsString;

import org.junit.Test;

public class SolrFullTextSearchTest {

	@Test
	public void shouldSupportQueriesOnProperties() throws Exception {
		
		httpAssert().body("select?q=fullTextSearchField:place&fq=type:objectProperty", containsString("http://dbpedia.org/ontology/birthPlace"));
	}

	@Test
	public void shouldSupportQueriesOnConcepts() throws Exception {
		
		httpAssert().body("select?q=fullTextSearchField:place&fq=type:concept", containsString("http://dbpedia.org/ontology/PopulatedPlace"));
	}
	
	@Test
	public void shouldSupportQueriesOnAKPs() throws Exception {
		
		httpAssert().body("select?q=fullTextSearchField:place&fq=type:objectAkp", containsString("http://dbpedia.org/ontology/capital"));
	}
	
	private HttpAssert httpAssert() {
		return new HttpAssert("http://localhost/solr/indexing");
	}
}
