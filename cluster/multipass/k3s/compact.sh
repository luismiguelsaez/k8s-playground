
OS_VERSION="22.04"
K3S_VERSION="V1.24.9"

function create(){
  multipass launch -c 1 -m 1G -d 4G -n k3s-master ${OS_VERSION}
  multipass exec k3s-master -- bash -c "curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC=\"server\" INSTALL_K3S_VERSION=\"${K3S_VERSION}\" sh -"

  TOKEN=$(multipass exec k3s-master sudo cat /var/lib/rancher/k3s/server/node-token)
  IP=$(multipass info k3s-master | grep IPv4 | awk '{print $2}')

  for f in 1 2; do
    multipass launch -c 1 -m 1G -d 4G -n k3s-worker-$f ${OS_VERSION}
  done

  for f in 1 2; do
    multipass exec k3s-worker-$f -- bash -c "curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC=\"agent\" INSTALL_K3S_VERSION=\"${K3S_VERSION}\" K3S_URL=\"https://$IP:6443\" K3S_TOKEN=\"$TOKEN\" sh -"
  done
}

function destroy(){
  multipass delete k3s-master

  for f in 1 2; do
    multipass delete k3s-worker-$f
    multipass purge
  done
}

if [ $# -lt 1 ]
then
  echo "Provide an action (create|delete)"
  exit 1
fi

if [ "$1" == "create" ]
then
  create
else
  destroy
fi
