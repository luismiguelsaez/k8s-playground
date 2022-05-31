

## Review `ClusterConfig` schema

```bash
eksctl utils schema
```

## Create a cluster from some [example](https://github.com/weaveworks/eksctl/blob/main/examples)

```bash
eksctl create cluster --profile lokalise-admin-dev --config-file complete-cluster.yaml
eksctl utils associate-iam-oidc-provider --cluster=test --approve
```

## Ingress configuration

### AWS [ingress controller](https://aws.amazon.com/blogs/opensource/kubernetes-ingress-aws-alb-ingress-controller/)
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/rbac-role.yaml
```

### Nginx

- Add helm chart
  ```bash
  helm repo add nginx-stable https://helm.nginx.com/stable
  ```
- Example `Service`
  ```yaml
  apiVersion: v1
  kind: Service
  metadata:
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-backend-protocol: tcp
      service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout: "3600"
      service.beta.kubernetes.io/aws-load-balancer-proxy-protocol: '*'
      service.beta.kubernetes.io/aws-load-balancer-ssl-cert: arn:aws:acm:us-east-1:1234567:certificate/1234294-232-4f89-bca8
      service.beta.kubernetes.io/aws-load-balancer-ssl-ports: https
    labels:
      k8s-addon: ingress-nginx.addons.k8s.io
    name: ingress-nginx
    namespace: ingress-nginx
  spec:
    externalTrafficPolicy: Cluster
    ports:
    - name: https
      port: 443
      protocol: TCP
      targetPort: http
    - name: http
      port: 80
      protocol: TCP
      targetPort: http
    selector:
      app: ingress-nginx
    type: LoadBalancer
  ```

## CICD

### ArgoCD

- Add helm chart
  ```bash
  helm repo add argo https://argoproj.github.io/argo-helm
  ```
## Delete cluster

```bash
eksctl delete cluster --profile lokalise-admin-dev --config-file two-node-groups.yaml
```
