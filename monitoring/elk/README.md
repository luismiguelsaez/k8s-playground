

```
helm repo add elastic https://helm.elastic.co
helm show values elastic/logstash
```

```
helm upgrade --install logstash elastic/logstash --create-namespace -n logging -f values/logstash.yaml --version 7.17.3
```
