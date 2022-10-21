# MicroK8s for deploying a Kubernetes cluster
> master and workers nodes
---

## list available versions:

```
snap info microk8s
```

## update your existing list of packages:

```
sudo apt-get update
```

## install MicroK8s version 1.23

```
sudo snap install microk8s --classic --channel=1.23/stable
```

## configure root privileges:

### add user to group microk8s (it will avoid the use of *sudo*):

```
sudo usermod -a -G microk8s username
```

### set access to the *.kube* caching:

```
sudo chown -f -R username ~/.kube
```

### re-enter the session for the group update to take place:

```
su - username
```

## check service status:

### display status and wait for Kubernetes services to start:

```
microk8s status --wait-ready
```

===
```
microk8s is running
high-availability: no
  datastore master nodes: 127.0.0.1:19001
  datastore standby nodes: none
addons:
  enabled:
    ha-cluster           # (core) Configure high availability on the current node
    helm                 # (core) Helm - the package manager for Kubernetes
    helm3                # (core) Helm 3 - the package manager for Kubernetes
  disabled:
    cert-manager         # (core) Cloud native certificate management
    community            # (core) The community addons repository
    dashboard            # (core) The Kubernetes dashboard
    dns                  # (core) CoreDNS
    gpu                  # (core) Automatic enablement of Nvidia CUDA
    host-access          # (core) Allow Pods connecting to Host services smoothly
    hostpath-storage     # (core) Storage class; allocates storage from host directory
    ingress              # (core) Ingress controller for external access
    kube-ovn             # (core) An advanced network fabric for Kubernetes
    mayastor             # (core) OpenEBS MayaStor
    metallb              # (core) Loadbalancer for your Kubernetes cluster
    metrics-server       # (core) K8s Metrics Server for API access to service metrics
    observability        # (core) A lightweight observability stack for logs, traces and metrics
    prometheus           # (core) Prometheus operator for monitoring and logging
    rbac                 # (core) Role-Based Access Control for authorisation
    registry             # (core) Private image registry exposed on localhost:32000
    storage              # (core) Alias to hostpath-storage add-on, deprecated
```
===

---