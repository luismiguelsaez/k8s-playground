# Create `configmap`
```
k create cm fluentd --from-file=fluentd.conf
```

# Create `deployment`
```
k apply -f deployment.yaml
```

