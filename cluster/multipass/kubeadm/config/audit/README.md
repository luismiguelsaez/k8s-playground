
# Audit policy configuration ( apiserver )

- Create directories
  ```bash
  sudo mkdir -p /etc/kubernetes/audit -p /var/log/kubernetes/audit
  ```

- Copy policy
  ```bash
  cp config/audit/policy.yaml kubeadm-control-1:/etc/kubernetes/audit
  ```

- Configure audit options for apiserver
  ```bash
  sudo vi /etc/kubernetes/manifests/kube-apiserver.yaml
  ```

  - Add options
    ```yaml
    spec:
      containers:
      - command:
        - kube-apiserver
        - --audit-policy-file=/etc/kubernetes/audit/policy.yaml
        - --audit-log-path=/var/log/kubernetes/audit/audit.log
        - --audit-log-maxage=5
        - --audit-log-maxbackup=10
        - --audit-log-maxsize=10
    ```

  - Add volumes
    ```yaml
    volumes:
    - hostPath:
        path: /etc/kubernetes/audit/policy.yaml
        type: File
      name: audit-config
    - hostPath:
        path: /var/log/kubernetes/audit
        type: DirectoryOrCreate
      name: audit-logs
    ```

  - Mount volumes
    ```yaml
    volumeMounts:
    - mountPath: /etc/kubernetes/audit/policy.yaml
      name: audit-config
      readOnly: true
    - mountPath: /var/log/kubernetes/audit
      name: audit-logs
      readOnly: false
    ```

- Wait for `kube-apiserver` to restart

  - Check containers
    ```bash
    crictl ps
    ```

  - Check logs
    - `/var/log/pods/kube-system_kube-apiserver-*`
    - `/var/log/containers/kube-apiserver-*`

- Check audit logs
  ```bash
  sudo cat /var/log/kubernetes/audit/audit.log | jq -r '[.user.username,.verb,.objectRef.name]|@csv'
  ```
