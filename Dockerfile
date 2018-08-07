FROM docker.elastic.co/kibana/kibana:5.6.9

RUN bin/kibana-plugin install https://github.com/ppadovani/KibanaNestedSupportPlugin/releases/download/5.6.9-1.0.2/nested-fields-support-5.6.9-1.0.2.zip
