#  Add a worker to the Kubernetes cluster.
---

## install MicroK8s on each node we want to add to the cluster:

### update your existing list of packages:

```
sudo apt-get update
```

### install Microk8s:

```
sudo snap install microk8s --classic --channel=1.23/stable
```

### add a node by running the following command:
> on the master node:

```
microk8s add-node
```

===
```
From the node you wish to join to this cluster, run the following:
microk8s join A.B.C.D:25000/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/xxxxxxxxxxxx

Use the '--worker' flag to join a node as a worker not running the control plane, eg:
microk8s join A.B.C.D:25000/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/xxxxxxxxxxxx --worker

If the node you are adding is not reachable through the default interface you can use one of the following:
microk8s join A.B.C.D:25000/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/xxxxxxxxxxxx
microk8s join E.F.G.H:25000/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/xxxxxxxxxxxx
microk8s join I.J.K.L:25000/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/xxxxxxxxxxxx
```
===

### join the node as a worker:
> from the worker node:

```
microk8s join A.B.C.D:25000/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/xxxxxxxxxxxx --worker
```

## add NFS support:
> on the worker nodes:

### install package:
sudo apt install nfs-common

### check NFS volume can be mounted
sudo mount -t nfs xxx.xxx.xxx.xxx:/foldername/username /mnt

sudo umount /mnt

## list all nodes of the cluster by executing the following:
> on the master node:

```
microk8s kubectl get nodes
```
===
```
NAME       STATUS   ROLES    AGE    VERSION
workerNode   Ready    <none>   4h2m   v1.23.10-2+b9088462d1df8c
masterNode     Ready    <none>   47h    v1.23.10-2+b9088462d1df8c
```
===

## remove a node from the cluster:

### on the node to be removed:

```
microk8s leave
```

### on the master node:

```
microk8s remove-node nodename
```

>  it will restart its own control plane and resume operations as a full single node cluster. 

---