
# Challenge 3

## Download and execute `kube-bench` in the nodes

- Download 'kube-bench' from AquaSec and extract it under '/opt' filesystem. Use the appropriate steps from the kube-bench docs to complete this task.

  - [Docs](https://github.com/aquasecurity/kube-bench/blob/main/docs/installation.md)
  - Install tool from [releases](https://github.com/aquasecurity/kube-bench/releases/tag/v0.6.8)
    ```bash
    curl -sL https://github.com/aquasecurity/kube-bench/releases/download/v0.6.8/kube-bench_0.6.8_linux_amd64.tar.gz -o /opt/kube-bench.tar.gz
    cd /opt
    tar -xzf kube-bench.tar.gz
    ```

- Run 'kube-bench' with config directory set to '/opt/cfg' and '/opt/cfg/config.yaml' as the config file. Redirect the result to '/var/www/html/index.html' file.

  - Run tool
    ```bash
    mkdir -p /var/www/html
    /opt/kube-bench --config-dir /opt/cfg --config /opt/cfg/config.yaml > /var/www/html/index.html
    ```
