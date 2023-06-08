#  Configuration Kubernetes.
> master node (as admin)
---

## change local path for microk8s container data:
> both, in the master and worker nodes

### create path:
```
sudo mkdir -p /data/microk8s/var/lib/containerd
sudo mkdir -p /data/microk8s/run/containerd
```

### change group:
```
sudo chgrp microk8s /data/microk8s/var/lib/containerd
sudo chgrp microk8s /data/microk8s/run/containerd
```

### edit file */var/snap/microk8s/current/args/containerd* 

#### change --root and --state paths to point to */data*
```
--root /data/microk8s/var/lib/containerd
--state /data/microk8s/run/containerd
```

### restart MicroK8s
```
microk8s stop
microk8s start
```

---

## set the maximum number of pods per node:
> by default 110

### edit master and worker nodes by adding:

```
--max-pods=140
```
### to the following file:

```
sudo nano /var/snap/microk8s/current/args/kubelet
```

### restart the service:
#### master node:

```
microk8s stop
microk8s start
```

#### worker nodes:

```
sudo snap stop microk8s
sudo snap start microk8s
```

### check it:

```
kubectl get node nodeName -ojsonpath='{.status.capacity.pods}{"\n"}'
```

---

## use only the master node to run jobs:

```
microk8s kubectl cordon workerNode
```

> it will cordon the node (marking it with the NoSchedule taint, so that no new workloads are scheduled on it).

```
microk8s kubectl drain workerNode
```

> it will cordon the node (marking it with the NoSchedule taint, so that no new workloads are scheduled on it), as well as evicting all running pods to other nodes.

---

## remove an existing image from MicroK8s
> in master and worker nodes:

### list images and filter by docker.io/fortunalab:

```
microk8s ctr images check | awk '{ print $1 }' | grep docker.io/fortunalab
```

### remove the image:

```
microk8s ctr images remove docker.io/fortunalab/avida:2.15.alpine
```

### check that the image no longer exist:

```
microk8s ctr images check | awk '{ print $1 }' | grep docker.io/fortunalab
```

---