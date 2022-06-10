

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

## Ingress configuration

### AWS [load balancer controller](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html)

- Github repo: https://github.com/kubernetes-sigs/aws-load-balancer-controller/blob/main/docs/deploy/installation.md
- eksctl docs: https://www.eksworkshop.com/beginner/180_fargate/prerequisites-for-alb/
- Annotations ( https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/ )
  - Service: https://github.com/kubernetes-sigs/aws-load-balancer-controller/blob/main/docs/guide/service/annotations.md
  - Ingress: https://github.com/kubernetes-sigs/aws-load-balancer-controller/blob/main/docs/guide/ingress/annotations.md

- Install controller
  ```bash
  helm repo add eks https://aws.github.io/eks-charts
  helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=single-ng-lb-controller --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller --set region=eu-central-1 --set vpcId=vpc-047f2fc64d0ea743f
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
