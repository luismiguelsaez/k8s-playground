
kubectl apply -f pod-2-container.yaml
kubectl exec multi-echo -c echo-2 -- ls
