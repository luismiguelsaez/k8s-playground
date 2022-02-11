
## Creating cluster
```
vagrant up
```

## Shutting nodes down

After issuing `vagrant halt` command, nodes aren't starting again properly, so we are going to shut them down from command

```
for node in worker-02 worker-01 control-01
do
  vagrant ssh ${node} -c "sudo shutdown -h 0"
done
```

To bring them up again, we can use the `vagrant up --no-provision` command
