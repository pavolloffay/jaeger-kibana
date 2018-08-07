# Jaeger Kibana

Project guidelines how to use Jaeger with Kibana

## Searching on Tags

How to search on tags/logs (nested datatypes).

### KibanaNestedSupportPlugin

This approach uses custom Kibana plugin [KibanaNestedSupportPlugin](https://github.com/ppadovani/KibanaNestedSupportPlugin).
The disadvantage might be that plugin uses different query language [KNQL](https://ppadovani.github.io/knql_plugin/knql/) which
is similar to SQL. Note that standard query (e.g. `operationName:foo`) does not
work when the plugin is enabled.

Start ES and Jaeger:
```
docker run -it --rm -e "ES_JAVA_OPTS=-Xms2g -Xmx2g" -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" -e "xpack.security.enabled=false" --name=elasticsearch  docker.elastic.co/elasticsearch/elasticsearch:5.6.9
SPAN_STORAGE_TYPE=elasticsearch go run  -tags ui ./cmd/standalone/main.go
```

Build Kibana image with the plugin and run it:
```
docker build -t kibana-nested .
docker run --rm -it --link=elasticsearch --name=kibana  -e "xpack.security.enabled=false"  -p 5601:5601 kibana-nested
```

Kibana configuration:
1. Create index pattern jaeger-span*
2. Management -> Nested Fields -> Checkbox "Enable nested fields support"


Kibana sometimes fails with the following errors. Just remove Kibana
container and start it again (do not stop Elasticsearch!).

From server logs:
```
Unhandled rejection [index_not_found_exception] no such index, with { resource.type="index_or_alias" & resource.id=".kibana" & index_uuid="_na_" & index=".kibana" } :: {"path":"/.kibana/_mapping/index-pattern","query":{},"body":"{\"properties\":{\"nested\":{\"type\":\"boolean\"}}}","statusCode":404,"response":"{\"error\":{\"root_cause\":[{\"type\":\"index_not_found_exception\",\"reason\":\"no such index\",\"resource.type\":\"index_or_alias\",\"resource.id\":\".kibana\",\"index_uuid\":\"_na_\",\"index\":\".kibana\"}],\"type\":\"index_not_found_exception\",\"reason\":\"no such index\",\"resource.type\":\"index_or_alias\",\"resource.id\":\".kibana\",\"index_uuid\":\"_na_\",\"index\":\".kibana\"},\"status\":404}"}
    at respond (/usr/share/kibana/node_modules/elasticsearch/src/lib/transport.js:295:15)
    at checkRespForFailure (/usr/share/kibana/node_modules/elasticsearch/src/lib/transport.js:254:7)
    at HttpConnector.<anonymous> (/usr/share/kibana/node_modules/elasticsearch/src/lib/connectors/http.js:159:7)
    at IncomingMessage.bound (/usr/share/kibana/node_modules/elasticsearch/node_modules/lodash/dist/lodash.js:729:21)
    at emitNone (events.js:91:20)
    at IncomingMessage.emit (events.js:185:7)
    at endReadableNT (_stream_readable.js:974:12)
    at _combinedTickCallback (internal/process/next_tick.js:80:11)
    at process._tickCallback (internal/process/next_tick.js:104:9)

```

From Kibana UI:
```
Error: mapping set to strict, dynamic introduction of [nested] within [index-pattern] is not allowed: [strict_dynamic_mapping_exception] mapping set to strict, dynamic introduction of [nested] within [index-pattern] is not allowed
    at http://localhost:5601/bundles/commons.bundle.js?v=15629:139:11663
    at processQueue (http://localhost:5601/bundles/commons.bundle.js?v=15629:38:23621)
    at http://localhost:5601/bundles/commons.bundle.js?v=15629:38:23888
    at Scope.$eval (http://localhost:5601/bundles/commons.bundle.js?v=15629:39:4619)
    at Scope.$digest (http://localhost:5601/bundles/commons.bundle.js?v=15629:39:2359)
    at Scope.$apply (http://localhost:5601/bundles/commons.bundle.js?v=15629:39:5037)
    at done (http://localhost:5601/bundles/commons.bundle.js?v=15629:37:25027)
    at completeRequest (http://localhost:5601/bundles/commons.bundle.js?v=15629:37:28702)
    at XMLHttpRequest.xhr.onload (http://localhost:5601/bundles/commons.bundle.js?v=15629:37:29634)
```

Now you can use following query on Discover page `operationName = "foo" AND  tags.value= "15" AND tags.key="root.child55"`.

[kibana-nested-support-plugin]: kibana-nested-plugin-support-plugin.jpg "Kibana nested support plugin"
