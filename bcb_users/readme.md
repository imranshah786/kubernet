# Helm Chart for users.

The **Helm chart** *username-gateway* that will be installed deploys a pod, serving as an entry point to our Kubernetes-managed cluster. It will equip users with everything needed to efficiently run their jobs. Users can upload and retrieve data via the *SFTP* protocol and launch jobs on the cluster directly from their terminal. The chart also creates the necessary service account and its associated secret, and deploys the pod using this service account, ensuring proper authentication and access control within the cluster.

### create a pod to serve as an entry point for the user:

``microk8s helm3 install username-gateway . --namespace username-namespace --set serviceAccount.name=username --set nfs.server=10.0.0.xxx --set nfs.path=/nfs/username --set sftp.password=xxxxx --set jobs.node=nodename``

> **What does this Helm Chart do?** a pod will be created in the storage node *nodename*, allowing the user to upload files and folders via *SFTP* and then connect via *SSH* to work without installing anything on his/her local computer. Once the user logs in from the local computer's terminal, he/she can copy *YAML* files to be executed (including creating *PVC* for permanent storage). When the job is finished, the user can access the system via *SFTP* to download the resulting data. It will also create the *username* service account.
