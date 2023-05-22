# LENS, the Kubernetes IDE:

"<i>Lens Desktop works with any Kubernetes. It removes complexity and increases productivity. It’s used by everyone — from devs to ops and startups to large companies</i>...", Mirantic Inc.

---

## installation (from the Lens apt repo):

### get the lens public security key and add it to your keyring:
```
curl -fsSL https://downloads.k8slens.dev/keys/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/lens-archive-keyring.gpg > /dev/null
```

### add the lens repo to your /etc/apt/sources.list.d directory:
```
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/lens-archive-keyring.gpg] https://downloads.k8slens.dev/apt/debian stable main" | sudo tee /etc/apt/sources.list.d/lens.list > /dev/null
```

### install or update Lens Desktop:
```
sudo apt update
sudo apt install lens
```

## execute and activate LENS:
```
lens-desktop
```

you should create an user account at LENS website and follow activation instructions when running LENS for the first time.

## add a cluster to LENS:

### as MicroK8s admin:
it will automatically get the full-access account specified in the kubeconfig file located at /var/snap/microk8s/current/credentials/client.config.

### as MicroK8s user:
it will automatically get the limited-access account specified in the user's ~/.kube/kubeconfig file.

## add a cluster manually:
useful for us to manage the Kubernetes cluster from a remote location. We have to provide (i.e., copy and paste) the content of the i) */var/snap/microk8s/current/credentials/client.config* file if we access as admin, or ii) the *~/.kube/kubeconfig* file if access as user to LENS when adding the cluster (after changing the server IP to access the cluster from a remote location).

> to avoid LENS writting a kubeconfig file everytime the user access the cluster, copy and paste the content of the user's ~/.kube/kubeconfig directly in the LENS graphical interface

---