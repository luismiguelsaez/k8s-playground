

## Review `ClusterConfig` schema

```bash
eksctl utils schema
```

## Export AWS vars
```bash
export AWS_PROFILE=""
```

## Create a cluster from some [example](https://github.com/weaveworks/eksctl/blob/main/examples)

```bash
eksctl create cluster --config-file cloud/aws/eksctl/single-ng-cluster.yaml
```

## Update cluster after adding new nodegroup to config file

```bash
eksctl create nodegroup --config-file cloud/aws/eksctl/single-ng-cluster.yaml --include='monitoring'
```

### Install infra components

- [load balancer controller](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html)
- [external-dns](https://github.com/kubernetes-sigs/external-dns)

```
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns
helm repo add eks https://aws.github.io/eks-charts

helm upgrade --install -n kube-system --create-namespace external-dns external-dns/external-dns -f values/external-dns.yaml
helm upgrade --install -n kube-system --create-namespace aws-load-balancer-controller eks/aws-load-balancer-controller -f values/aws-load-balancer-controller.yaml
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
  helm install argocd argo/argo-cd -n argocd --values cloud/aws/charts/argo-cd/values.yaml --create-namespace --version 3.33.6
  ```
- Test locally
  ```bash
  k port-forward svc/argocd-eks-test 8080:80 -n argocd
  ```
- Add private repo
  ```
  argocd login http://<server> --grpc-web --insecure --username admin --password $(kubectl get secret argocd-initial-admin-secret -o jsonpath={.data.password} | base64 -d)

  argocd repo add git@github.com:test/test.git --grpc-web --ssh-private-key-path ~/.ssh/id_rsa
  ```

## Delete cluster

```bash
eksctl delete cluster --region=eu-central-1 --name=single-ng-lb-controller 
```
