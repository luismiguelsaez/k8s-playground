

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

## Ingress configuration

### AWS [load balancer controller](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html)

- Github repo: https://github.com/kubernetes-sigs/aws-load-balancer-controller/blob/main/docs/deploy/installation.md
- eksctl docs: https://www.eksworkshop.com/beginner/180_fargate/prerequisites-for-alb/
- Annotations: https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/

- Install controller
  ```bash
  helm repo add eks https://aws.github.io/eks-charts
  helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=single-ng-lb-controller --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller --set region=eu-central-1 --set vpcId=vpc-0d6aa2304efd1cae4
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
aws iam delete-policy --policy-arn arn:aws:iam::484308071187:policy/AWSLoadBalancerControllerIAMPolicy
```
```bash
eksctl delete cluster --config-file two-node-groups.yaml
```
