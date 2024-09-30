# Create a docker image to set up an SFTP server as an entry point to Kubernetes.

we will create a docker image to set up an *SFTP* server, which will serve as the entry point for users to access our Kubernetes-managed cluster. The *SFTP* server will allow users to upload files and connect via *SSH*, enabling them to interact with the cluster without needing to install any additional tools on their local machines. We will also configure the necessary services to ensure smooth communication between the *SFTP* server and the Kubernetes cluster.

## required bash scripts:
We will use the following bash scripts to create the *SFTP* server, configure the *SSH* service, set up the entry point to access our Kubernetes-managed cluster, and generate the kubeconfig file needed for the user to interact with Kubernetes.

- create-sftp-user.sh
- entrypoint.sh
- generate-kube-config.sh
- sshd_config.sh

## build image:
``docker build -f Dockerfile -t ebdbcb/sftp:latest .``

## check the user currently logged in DockeHub:
``docker info``

## in case you want to change the user currently logged in:
``docker logout``

## enter the new DockerHub username and password:
``docker login``

## pull image to DockerHub:
``docker push ebdbcb/sftp:latest``
