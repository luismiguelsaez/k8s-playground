
## Install CLI

```bash
curl -sL https://github.com/fluxcd/flux2/releases/download/v0.30.2/flux_0.30.2_linux_amd64.tar.gz -o ~/.local/bin/flux
chmod +x ~/.local/bin/flux
```

## Local testing

```bash
flux install
```

### Create source

- Helm
  ```bash
  flux create source helm bitnami \
    --interval=1h \
    --url=https://charts.bitnami.com/bitnami

  flux get sources helm

  flux create helmrelease nginx \
    --interval=5m \
    --release-name=nginx \
    --create-target-namespace \
    --target-namespace=ws \
    --source=HelmRepository/bitnami \
    --chart=nginx \
    --chart-version="12.0.0" \
    --values cloud/aws/charts/nginx/values.yaml

  flux reconcile helmrelease nginx
  ```

## Github setup

- Docs
  - Repo structure: https://fluxcd.io/docs/guides/repository-structure/
  - Example structure: https://github.com/fluxcd/flux2-kustomize-helm-example

- Create access token

- Bootstrap repo ( https://github.com/luismiguelsaez/fluxcd-playground )

  - Empty repository
    ```bash
    flux bootstrap github \
      --owner=luismiguelsaez \
      --repository=fluxcd-playground \
      --path=clusters/minikube \
      --personal
    ```
  - Existing repository
    ```bash
    flux bootstrap github \
      --context=minikube \
      --owner=luismiguelsaez \
      --repository=fluxcd-playground \
      --branch=main \
      --personal \
      --path=clusters/live \
      --timeout=10m
    ```
  - Terraform provider: https://registry.terraform.io/providers/fluxcd/flux/latest/docs/guides/github
