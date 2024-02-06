# Set up a persistent volume
> master node

We will deploy a job running avida that uses persistent volumes. Once avida finished, it will copy the output files from the local folder */data/* to a shared folder. The shared folder is hosted by a NFS server, that will run on one of the workers. Kubernetes will set up a persistent volume that will be *alive* during the job execution. All data copied to the persistent volume will be kept on the shared folder as long as the job is not deleted.

---

## enable services:

### enable addons:
> only in the master node

```
dns                  # CoreDNS
helm3                # Helm 3 - Kubernetes package manager
metrics-server       # K8s Metrics Server for API access to service metrics
storage              # Storage class; allocates storage from host directory
```

## setup the NFS server:

### update your existing list of packages:

```
sudo apt-get update
```

### install the NFS server:

```
sudo apt-get install nfs-kernel-server
```

### create a folder to mount the NFS volume:

```
sudo mkdir -p /nfs
```

### mount the NFS volume:

```
sudo mount /dev/sdx /nfs
```

### change owner and group:

```
sudo chown nobody:nogroup /nfs
```

### change permissions:

```
sudo chmod 0777 /nfs
```

### allow master and worker nodes to access to the NSF volume:

```
sudo mv /etc/exports /etc/exports.bak
```

```
echo -e '/nfs xxx.xxx.xxx.xxxx(rw,sync,no_subtree_check)' | sudo tee /etc/exports # master
echo -e '/nfs xxx.xxx.xxx.xxx(rw,sync,no_subtree_check)' | sudo tee -a /etc/exports # worker
```

### restart the NFS server:

```
sudo systemctl start nfs-kernel-server
```

## install the CSI driver for NFS

### add the repository for the NFS CSI driver:

```
microk8s helm3 repo add csi-driver-nfs https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts
microk8s helm3 repo update
```

### install the Helm chart under the kube-system namespace:

```
microk8s helm3 install csi-driver-nfs csi-driver-nfs/csi-driver-nfs \
    --namespace kube-system \
    --set kubeletDir=/var/snap/microk8s/common/var/lib/kubelet
```

### wait for the CSI controller and node pods to come up:

```
microk8s kubectl wait pod --selector app.kubernetes.io/name=csi-driver-nfs --for condition=ready --namespace kube-system
```

===
```
pod/csi-nfs-controller-67bd588cc6-7vvn7 condition met
pod/csi-nfs-node-qw8rg condition met
```
===

### list the available CSI drivers:

```
k get csidrivers
```

===
```
NAME             ATTACHREQUIRED   PODINFOONMOUNT   STORAGECAPACITY   TOKENREQUESTS   REQUIRESREPUBLISH   MODES        AGE
nfs.csi.k8s.io   false            false            false             <unset>         false               Persistent   31m
```
===

## install nfs-common package in worker nodes:
```
sudo apt install nfs-common
```
---