#! /bin/bash

set -e

server_port=8880

ssh $1 "export GIT_SSH=~/schema-summaries/scripts/git+ssh.sh && cd ~/schema-summaries && git checkout master && git pull && scripts/test-summarization-pipeline.sh && scripts/isql.sh 'SPARQL CLEAR GRAPH <http://ld-summaries.org/system-test>;' && scripts/build-java-ui-module.sh && scripts/java-ui-production.sh stop $server_port && scripts/java-ui-production.sh start $server_port"

