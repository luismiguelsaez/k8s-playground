
# Create cluster

- Create infra
  ```bash
  terraform init
  terraform plan
  terraform apply
  ```

- Get credentials
  ```bash
  aws eks update-kubeconfig --name k8s-test
  ```

# Cillium install ( [docs](https://docs.cilium.io/en/v1.9/gettingstarted/k8s-install-eks/) )

- Install `Cilium CNI` ( CLI )
  ```bash
  curl -sL https://github.com/cilium/cilium-cli/releases/download/v0.12.0/cilium-linux-amd64.tar.gz | tar -xz -C /tmp
  sudo mv /tmp/cilium /usr/local/bin
  
  cilium install --k8s-version 1.22 -n kube-system
  cilium status --wait
  ```

- Install `Cilium CNI` ( Helm )
  ```bash
  helm repo add cilium https://helm.cilium.io/
  
  helm install cilium cilium/cilium --version 1.12.0 \
    --namespace kube-system \
    --set cni.chainingMode=aws-cni \
    --set enableIPv4Masquerade=false \
    --set tunnel=disabled
  ```

- Test
  ```
  k create deploy nginx --image=nginx:1.20.1-alpine --replicas=6 --port=80 -n default
  k expose deploy nginx --name=nginx --port=8080 --target-port=80
  k run test --image=busybox --rm -it --command -- sh -c "wget -O- --timeout 2 http://nginx.default.svc:8080"
  ```

# Install `aws-load-balancer-controller`

- Install from Helm repo
  ```bash
  helm show values eks/aws-load-balancer-controller

  helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system -f aws-load-balancer-controller/values.yaml
  ```

- Test

  - Export vars
    ```bash
    EXTERNAL_DNS_NAME=test.example.com
    ```

  - NLB
    ```bash
    k expose deploy nginx --name=nginx --port=8080 --target-port=80 --type=LoadBalancer
    ```

  - ALB
    ```bash
    k expose deploy nginx --name=nginx --port=8080 --target-port=80 --type=NodePort

    cat << EOF | k apply -f -
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: nginx
      namespace: default
      annotations:
        kubernetes.io/ingress.class: alb
        alb.ingress.kubernetes.io/scheme: internet-facing
        alb.ingress.kubernetes.io/inbound-cidrs: 0.0.0.0/0
        alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}]'
      labels:
        app: nginx
    spec:
      rules:
        - host: ${EXTERNAL_DNS_NAME:-nginx.example.com}
          http:
            paths:
            - path: /
              pathType: Prefix
              backend:
                service:
                  name: nginx
                  port:
                    number: 8080
    EOF
    ```

# Install `external-dns`

- [docs](https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md)

- Install from Helm repo
  ```
  helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/

  helm upgrade --install external-dns external-dns/external-dns -n kube-system -f external-dns/values.yaml
  ```

# ArgoCD autopilot install

- [docs](https://github.com/argoproj-labs/argocd-autopilot)

- Bootstrap repo
  ```
  argocd-autopilot repo bootstrap -n argocd --upsert-branch test-autopilot --repo https://github.com/luismiguelsaez/argocd-playground --git-token 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
  ```
