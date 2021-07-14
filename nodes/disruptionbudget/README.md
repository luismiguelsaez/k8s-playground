Testing podDisruptionBudget
===========================

We're going to use the official Helm chart to deploy an Elasticsearch cluster

## Create kind k8s cluster
```
kind create cluster --config kind-cluster.yaml --name elasticsearch
```

## Install chart ( https://github.com/elastic/helm-charts/tree/master/elasticsearch#installing )
### Add repo
```
helm repo add elastic https://helm.elastic.co
```
### Edit values file to configure deployment ( https://github.com/elastic/helm-charts/blob/master/elasticsearch/values.yaml )

### Deploy cluster
```
helm install elasticsearch elastic/elasticsearch -f values.yaml
```
