# How to access the cluster.
> you should replace *username* accordingly.
---

## requirements for the user:
- a VPN connection is required if the user is outside the local network.
- *kubectl* must be installed in the local computer of the user (https://kubernetes.io/docs/tasks/tools/#kubectl).
- the user must copy the kube config file we provide to the local folder of the user's computer (e.g., for GNU/Linux users: *~/.kube/username*)
- the user should be familiar with *kubectl* commands to interact with the cluster.

## requirements for the admin:
> from the master node

### create a NFS path in the storage node for the user *username*. 

``sudo mkdir /nfs/bcb/username``

``sudo chown -R nogroup:nogroup /nfs/bcb/username``

### create the namespace *username* as:

``microk8s kubectl create namespace username-namespace``

### execute helm as:

``microk8s helm3 install generic-workflow . --namespace username-namespace --set serviceAccount.name=username --set nfs.server=10.0.0.xxx --set nfs.path=/nfs/username --set sftp.password=xxxxx --set jobs.node=nodename``

> **What does heml do?** a pod will be created in the storage node *nodename*, allowing the user to upload files and folders via *SFTP* and then connect via *SSH* to work without installing anything on his/her local computer. Once the user logs in from the local computer's terminal, he/she can copy *YAML* files to be executed (including creating *PVC* for permanent storage). When the job is finished, the user can access the system via *SFTP* to download the resulting data. It will also create the *username* service account.

> **What's next?** The user will receive a *URL* to connect via *SFTP* and *SSH* to interact with the cluster. Once the job is finished, the user must delete the job.

### get url for access:

``export NODE_PORT=$(microk8s kubectl get --namespace username-namespace -o jsonpath="{.spec.ports[0].nodePort}" services username-workflow-agvc)``

``export NODE_IP=$(microk8s kubectl get nodes --namespace username-namespace -o jsonpath="{.items[0].status.addresses[0].address}")``

``echo sftp://$NODE_IP:$NODE_PORT``

### create the kube config file for the user:
#### write the kubeconfig file:

``
microk8s kubectl view-serviceaccount-kubeconfig username-service-account -n username-namespace > ~/.kube/kubeconfig/username
``

#### replace the local IP by the server IP in the kubeconfig file (master node):

``
sed -i 's/127.0.0.1/xxx.xxx.xxx.xxx/g' ~/.kube/kubeconfig/username
``

#### provide this file to the user:

``
~/.kube/kubeconfig/username
``

### uninstall chart helm:
``microk8s helm3 delete username-generic-workflow-8djre --namespace username-namespace``

### delete namespace:
``microk8s kubectl delete namespace username-namespace``    
