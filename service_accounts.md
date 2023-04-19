# Service account to access Kubernetes.
We will set limited privilegies to users so that they cannot access the cluster as admin. This will cause *kubectl* stand alone to take into username context to manage Kubernetes API.
> master node
---

## enable RBAC addon:
```
microk8s enable rbac
```

## install stand alone kubectl:
> optional

```
sudo snap install kubectl --classic
```

## install krew:
> a tool that helps install kubectl plugins.

### script to install Krew:

```
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)
```

### add the krew to your PATH environment variable (i.e., update your *~/.bashrc* file and append the following line:

```
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
```

### reload source:

```
source ~/.bashrc
```

## install a required plugin for kubectl:

```
kubectl krew install view-serviceaccount-kubeconfig
```

## create namespace, service account, roles, and bindings for a user:

### write the [username.yaml](https://gitlab.com/fortunalab/kubernetes/-/raw/master/accounts/username.yaml) file as follows:
> do not forget to specify the server IP (i.e., replace xxx.xxx.xxx.xxx by the IP of the NFS server)

```
# define Namespace
apiVersion: v1
kind: Namespace
metadata:
  name: username-namespace

---

# define StorageClass

apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: username-nfs-csi
  namespace: username-namespace
provisioner: nfs.csi.k8s.io
parameters:
  server: xxx.xxx.xxx.xxx
  share: xxx/username
reclaimPolicy: Delete
volumeBindingMode: Immediate
mountOptions:
  - hard
  - nfsvers=3

---

apiVersion: v1
kind: ServiceAccount
metadata:
  name: username-service-account
  namespace: username-namespace

---

apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: username-role
  namespace: bastian-namespace
rules:
- apiGroups: [""]
  resources: ["pods", "events", "persistentvolumes", "persistentvolumeclaims", "nodes", "proxy/nodes", "pods/log", "secrets", "services", "endpoints", "configmaps"]
  verbs: ["*"]
- apiGroups: [""]
  resources: ["namespaces"]
  verbs: ["get", "list"]
- apiGroups: ["batch"]
  resources: ["jobs"]
  verbs: ["*"]
- apiGroups: ["storage.k8s.io"]
  resources: ["storageclasses", "volumeattachments", "csinodes", "csidrivers"]
  verbs: ["*"]

---

apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: username-bind
  namespace: username-namespace
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: username-role
subjects:
- kind: ServiceAccount
  name: username-service-account
  namespace: username-namespace
  
---

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: username-storageclasses-role
  namespace: default
rules:
- apiGroups: ["storage.k8s.io"]
  resources: ["storageclasses", "volumeattachments", "csinodes", "csidrivers"]
  verbs: ["get","list"]
- apiGroups: [""]
  resources: ["nodes","persistentvolumes"]
  verbs: ["get","list"]
---

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: username-storageclasses-bind
  namespace: username-namespace
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: username-storageclasses-role
subjects:
- kind: ServiceAccount
  name: username-service-account
  namespace: username-namespace
```

## apply manifiest by reading the user yaml file from local or from our [gitlab repository](https://gitlab.com/fortunalab/kubernetes/-/tree/master/accounts):

```
microk8s kubectl apply -f username.yaml
microk8s kubectl apply -f https://gitlab.com/fortunalab/kubernetes/-/raw/master/accounts/username.yaml
```

===
```
namespace/username-namespace created
storageclass.storage.k8s.io/nfs-csi created
serviceaccount/username-service-account created
role.rbac.authorization.k8s.io/username-role created
rolebinding.rbac.authorization.k8s.io/username-bind created
clusterrole.rbac.authorization.k8s.io/username-storageclasses-role created
clusterrolebinding.rbac.authorization.k8s.io/username-storageclasses-bind created
```
===

## delete user account:

```
microk8s kubectl delete -f username.yaml
```

## the following steps were done when a user is created in the master node:

When using *kubectl* stand alone (i.e., as user instead of as admin), *kubectl* will get configuration from the user's *~/.kube/kubeconfig* file

### write the kubeconfig file:

```
microk8s kubectl view-serviceaccount-kubeconfig username-service-account -n username-namespace > ~/.kube/kubeconfig/username
```

#### replace the local IP by the server IP in the kubeconfig file (master node):

```
sed -i 's/127.0.0.1/xxx.xxx.xxx.xxx/g' ~/.kube/kubeconfig/username
```

#### copy this file to the user home folder:

```
cp ~/.kube/kubeconfig/username /home/username/.kube/kubeconfig
```

#### export the kubeconfig variable:
> it was already exported when the user was created

#### if it was not exported, do the following:

##### edit file *~/.bashrc* and add:

```
export KUBECONFIG=~/.kube/kubeconfig
```

##### and reload source:

```
source ~/.bashrc
```
---


