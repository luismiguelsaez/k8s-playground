https://learn.hashicorp.com/tutorials/vault/agent-kubernetes

## Create cluster

```bash
k3d cluster create --config k3d.yaml
```

## Create tunnel to reach LB

```bash
kubectl -n kube-system port-forward svc/traefik 8080:80
```

## Vault/k8s auth configuration

### Create service account

```bash
cat << EOF | k apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: vault-auth
  namespace: default
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: role-tokenreview-binding
  namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- kind: ServiceAccount
  name: vault-auth
  namespace: default
EOF
```

### Configure auth method

- Create test policy in Vault

```bash
vault policy write argocd-dev-rl - <<EOF
path "kv/data/internal/argocd/dev/*" {
    capabilities = ["read", "list"]
}

path "kv/data/*" {
    capabilities = ["read", "list"]
}

path "kv/metadatadata/*" {
    capabilities = ["read", "list"]
}
EOF
```

- Set `SA_SECRET_NAME` variable

```bash
export SA_SECRET_NAME=$(kubectl get secrets --output=json \
    | jq -r '.items[].metadata | select(.name|startswith("vault-auth-")).name')
```

- Set `SA_JWT_TOKEN` variable

```bash
export SA_JWT_TOKEN=$(kubectl get secret $SA_SECRET_NAME \
    --output 'go-template={{ .data.token }}' | base64 --decode)
```

- Set `SA_CA_CRT` variable

```bash
export SA_CA_CRT=$(kubectl config view --raw --minify --flatten \
    --output 'jsonpath={.clusters[].cluster.certificate-authority-data}' | base64 --decode)
```

- Set `K8S_HOST` variable

```bash
export K8S_HOST=$(kubectl config view --raw --minify --flatten \
    --output 'jsonpath={.clusters[].cluster.server}')
```

- Enable `k8s` auth method in Vault

```bash
vault auth enable kubernetes

vault write auth/kubernetes/config \
     token_reviewer_jwt="$SA_JWT_TOKEN" \
     kubernetes_host="$K8S_HOST" \
     kubernetes_ca_cert="$SA_CA_CRT" \
     issuer="https://kubernetes.default.svc.cluster.local"
```

- Create a role in Vault

```bash
vault write auth/kubernetes/role/vault-test \
     bound_service_account_names=vault-auth \
     bound_service_account_namespaces=default \
     policies=argocd-dev-rl \
     ttl=24h
```

- Check if vault can reach `K8S_HOST`

  - Added rule to `sg-0414016cd28a74a90` for `10.1.11.52/32` to connect to `443` ( k8s API server )

  - Create test `Pod`
    ```bash
    cat << EOF | k apply -f -
    apiVersion: v1
    kind: Pod
    metadata:
      name: devwebapp
      labels:
        app: devwebapp
    spec:
      serviceAccountName: vault-auth
      containers:
        - name: devwebapp
          image: burtlo/devwebapp-ruby:k8s
          env:
            - name: VAULT_ADDR
              value: "https://vault.minikube.cloud"
    EOF
    ```

  - Check
    ```bash
    keti devwebapp -- bash
    ```
    ```bash
    export KUBE_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)

    curl -X POST -sL --data '{"jwt": "'"$KUBE_TOKEN"'", "role": "vault-test"}' $VAULT_ADDR/v1/auth/kubernetes/login | jq -r .auth.token_policies
    [
      "argocd-dev-rl",
      "default"
    ]

    export VAULT_TOKEN=$(curl -X POST -sL --data '{"jwt": "'"$KUBE_TOKEN"'", "role": "vault-test"}' $VAULT_ADDR/v1/auth/kubernetes/login | jq -r .auth.client_token)

    # Download Vault client binary
    #./vault login -token-only -method=kubernetes role=vault-test
    ```