## Roles

- Create resources
```bash
k create namespace apps
k create serviceaccount apps-read -n apps
k create clusterrole apps-read -n apps --verb=get,list --resource=pod
k create clusterrolebinding apps-read -n apps --clusterrole=apps-read --serviceaccount=apps:apps-read
```

- Test
```bash
k auth can-i get pods --as=system:serviceaccount:apps:apps-read
# Result: yes
k auth can-i get secrets --as=system:serviceaccount:apps:apps-read
# Result: no
```
