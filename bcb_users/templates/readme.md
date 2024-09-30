# Structure and purpose of the Helm chart templates folder.

When creating a **Helm chart**, the templates folder is a critical component that contains the Kubernetes manifest files which *Helm* uses to deploy your application. The *templates* folder includes the following files:

- deployment.yaml
> handle the deployment and scaling of applications, ensuring that the desired state is maintained over time. The file includes specifications for the number of replicas (i.e.,  identical copies of a specific pod running at any given time), the container image to use, the container ports and the environment variables required.

- helpers.tpl
> helper functions can be called within other Helm template files (.yaml files like deployment.yaml, ingress.yaml, etc.) to avoid repetition and improve maintainability

- hpa.yaml
> defines an autoscaler to automatically adjusts the number of pod replicas in a deployment, replication controller, or replica set based on observed CPU utilization (or other select metrics).

- ingress.yaml
> defines rules for routing requests from outside the cluster to the appropriate services within it.

- secret.yaml
> create token for the user.

- service.yaml
> port forwarding from outside to inside the pod.

- serviceaccount.yaml
> create the user service account.
