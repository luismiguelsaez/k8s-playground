

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
- List values
  ```bash
  helm show values nginx-stable/nginx-ingress
  ```
- Install
  ```bash
  helm install nginx-ingress nginx-stable/nginx-ingress -n ingress --values cloud/aws/charts/nginx-ingress/values.yaml --create-namespace
  ```

## CICD

### ArgoCD

- Add helm chart
  ```bash
  helm repo add argo https://argoproj.github.io/argo-helm
  ```
- Install
  ```bash
  helm install argocd argo/argo-cd -n argocd --values cloud/aws/charts/argo-cd/values.yaml --create-namespace
  ```

## Delete cluster

```bash
eksctl delete cluster --profile lokalise-admin-dev --config-file two-node-groups.yaml
```
