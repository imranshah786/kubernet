# Monitoring Kubernetes.
> master node
---

## as admin:

### list user accounts:

``` 
microk8s kubectl get sa --all-namespaces
```

### list a specific user account:

``` 
microk8s kubectl get sa -n username-namespace
```

===
```
NAME                      SECRETS   AGE
default                   1         12m
username-service-account  1         12m
```
===

### list roles:

```
microk8s kubectl get role --all-namespaces
```

### list role bindings:

```
microk8s kubectl get rolebinding --all-namespaces
```

### list cluster roles:

```
microk8s kubectl get clusterrole --all-namespaces
``` 

### list cluster role bindings:

```
microk8s kubectl get clusterrolebinding --all-namespaces
```

### list persistent volumes:

```
microk8s kubectl get pvc -n username-namespace
```

===
```
NAME             STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS      AGE
avida-pv-claim   Bound    pvc-d54c8a3a-eba9-4bc4-b962-676bff3a67b5   1Gi        RWX            username-nfs-csi   9m12s
```
===

### list secrets:

```
microk8s kubectl get secrets -n username-namespace
```

### show tokens:

```
token=$(microk8s kubectl -n username-namespace get secret | grep username | cut -d " " -f1)
microk8s kubectl -n username-namespace describe secret $token
```

### list running services:

```
microk8s kubectl get services
```

===
```
NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.152.183.1   <none>        443/TCP   29m
```
===

### list jobs:

```
microk8s kubectl get jobs -n username-namespace
```

===
```
NAME                   COMPLETIONS   DURATION   AGE
username-job-default   0/4           35s        35s

```
===

### get job status:

```
microk8s kubectl describe -n username-namespace jobs/username-job-default
```    

===
```
Name:               username-job-default
Namespace:          username-namespace
Selector:           controller-uid=1a818ec0-5ce6-427e-977a-c5502e50a4fe
Labels:             controller-uid=1a818ec0-5ce6-427e-977a-c5502e50a4fe
                    job-name=username-job-default
Annotations:        <none>
Parallelism:        2
Completions:        4
Completion Mode:    Indexed
Start Time:         Thu, 20 Oct 2022 10:32:55 +0200
Pods Statuses:      2 Active / 2 Succeeded / 0 Failed
Completed Indexes:  0,1
Pod Template:
  Labels:  controller-uid=1a818ec0-5ce6-427e-977a-c5502e50a4fe
           job-name=username-job-default
  Containers:
   avida:
    Image:      fortunalab/avida:2.15.alpine.default
    Port:       <none>
    Host Port:  <none>
    Command:
      sh
      -exec
      cp /avida-config/* /avida/
      cd /avida
      chmod +x run-avida.sh
      ./run-avida.sh
      
    Limits:
      cpu:     800m
      memory:  300Mi
    Requests:
      cpu:     600m
      memory:  200Mi
    Environment:
      MY_NODE_NAME:   (v1:spec.nodeName)
      MY_POD_NAME:    (v1:metadata.name)
    Mounts:
      /avida-config from avida-vol-config (rw)
      /data from avida-pv-storage (rw)
  Volumes:
   avida-pv-storage:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  avida-pv-claim
    ReadOnly:   false
   avida-vol-config:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      avida-config
    Optional:  false
Events:
  Type    Reason            Age   From            Message
  ----    ------            ----  ----            -------
  Normal  SuccessfulCreate  109s  job-controller  Created pod: username-job-default-0-pz7gj
  Normal  SuccessfulCreate  109s  job-controller  Created pod: username-job-default-1-bdltj
  Normal  SuccessfulCreate  44s   job-controller  Created pod: username-job-default-2-nkzl2
  Normal  SuccessfulCreate  44s   job-controller  Created pod: username-job-default-3-mfbj6
```
===

### delete a job:

```
microk8s kubectl delete -f username-job-default.yaml
```

===
```
persistentvolumeclaim "avida-pv-claim" deleted
configmap "avida-config" deleted
job.batch "username-job-default" deleted
```
===


### list pods:

```
microk8s kubectl get pods -n username-namespace
```

===
```
NAME                           READY   STATUS    RESTARTS   AGE
username-job-default-0-78dzg   1/1     Running   0          14s
username-job-default-1-9lzzn   1/1     Running   0          14s

```
===

### list pods (wide output):

```
microk8s kubectl get pods -n username-namespace -o wide     
```

===
```
NAME                           READY   STATUS    RESTARTS   AGE   IP            NODE         NOMINATED NODE   READINESS GATES
username-job-default-0-78dzg   1/1     Running   0          33s   10.1.199.58   masterNode   <none>           <none>
username-job-default-1-9lzzn   1/1     Running   0          33s   10.1.199.8    masterNode   <none>           <none>
```
===

### list all about namespace *username-namespace*:
> a job batch named *username-job-default* has been created. This job has to perform 4 replicates (completions), and at the moment no one has been completed. Only two pods named, *username-job-default-1-gm8q2* and *username-job-default-0-fz6gl* have been created and are running in parallel. Once any of them finishes, the next pod will be created (i.e., more than 2 pods will never run at the same time) until the 4 pods (indexes 0 to 3) are completed.

```
microk8s kubectl -n username-namespace get all
```

===
```
NAME                               READY   STATUS    RESTARTS   AGE
pod/username-job-default-1-gm8q2   1/1     Running   0          9s
pod/username-job-default-0-fz6gl   1/1     Running   0          9s

NAME                             COMPLETIONS   DURATION   AGE
job.batch/username-job-default   0/4           9s         9s
```
===

### get access to a pod:

```
microk8s kubectl exec -n username-namespace --stdin --tty username-job-default-0-78dzg -- /bin/sh
```

### list output data:
> once the job is completed, the output contained in the */data* folder will be stored in the path */kubernetes/nfs/*:

```
ls -lt /kubernetes/nfs/username/pvc-* | grep "username-job-default"
```

===
```
-rw-r--r-- 1 nobody nogroup 0 Oct 20 10:51 username-job-default-2-gtmld.txt
-rw-r--r-- 1 nobody nogroup 0 Oct 20 10:51 username-job-default-3-xplnt.txt
-rw-r--r-- 1 nobody nogroup 0 Oct 20 10:50 username-job-default-1-gm8q2.txt
-rw-r--r-- 1 nobody nogroup 0 Oct 20 10:50 username-job-default-0-fz6gl.txt
```
===

---

## as user:

### list jobs:

```
kubectl get jobs
```

===
``` 
NAME                   COMPLETIONS   DURATION   AGE
username-job-default   0/4           35s        35s
``` 
===
    
### get job status:

```
kubectl describe jobs/username-job-default
```    

===
``` 
Name:               username-job-default
Namespace:          username-namespace
Selector:           controller-uid=1a818ec0-5ce6-427e-977a-c5502e50a4fe
Labels:             controller-uid=1a818ec0-5ce6-427e-977a-c5502e50a4fe
                    job-name=username-job-default
Annotations:        <none>
Parallelism:        2
Completions:        4
Completion Mode:    Indexed
Start Time:         Thu, 20 Oct 2022 10:32:55 +0200
Pods Statuses:      2 Active / 2 Succeeded / 0 Failed
Completed Indexes:  0,1
Pod Template:
  Labels:  controller-uid=1a818ec0-5ce6-427e-977a-c5502e50a4fe
           job-name=username-job-default
  Containers:
   avida:
    Image:      fortunalab/avida:2.15.alpine.default
    Port:       <none>
    Host Port:  <none>
    Command:
      sh
      -exec
      cp /avida-config/* /avida/
      cd /avida
      chmod +x run-avida.sh
      ./run-avida.sh
      
    Limits:
      cpu:     800m
      memory:  300Mi
    Requests:
      cpu:     600m
      memory:  200Mi
    Environment:
      MY_NODE_NAME:   (v1:spec.nodeName)
      MY_POD_NAME:    (v1:metadata.name)
    Mounts:
      /avida-config from avida-vol-config (rw)
      /data from avida-pv-storage (rw)
  Volumes:
   avida-pv-storage:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  avida-pv-claim
    ReadOnly:   false
   avida-vol-config:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      avida-config
    Optional:  false
Events:
  Type    Reason            Age   From            Message
  ----    ------            ----  ----            -------
  Normal  SuccessfulCreate  109s  job-controller  Created pod: username-job-default-0-pz7gj
  Normal  SuccessfulCreate  109s  job-controller  Created pod: username-job-default-1-bdltj
  Normal  SuccessfulCreate  44s   job-controller  Created pod: username-job-default-2-nkzl2
  Normal  SuccessfulCreate  44s   job-controller  Created pod: username-job-default-3-mfbj6
``` 
===

### delete a job:

```
kubectl delete -f username-job-default.yaml
```

===
```
persistentvolumeclaim "avida-pv-claim" deleted
configmap "avida-config" deleted
job.batch "username-job-default" deleted
```
===

### list pods:

```
kubectl get pods -n username-namespace
```

===
```
NAME                           READY   STATUS    RESTARTS   AGE
username-job--default0-78dzg   1/1     Running   0          14s
username-job--default1-9lzzn   1/1     Running   0          14s

```
===

### list pods (wide output):

```
kubectl get pods -n username-namespace -o wide     
```

===
```
NAME                           READY   STATUS    RESTARTS   AGE   IP            NODE         NOMINATED NODE   READINESS GATES
username-job-default-0-78dzg   1/1     Running   0          33s   10.1.199.58   masterNode   <none>           <none>
username-job-default-1-9lzzn   1/1     Running   0          33s   10.1.199.8    masterNode   <none>           <none>
```
===

### list pods under namespace *username-namespace*:
> a job batch named *username-job-default* has been created. This job has to perform 4 replicates (completions), and at the moment two of them been completed. The remaining two pods named, *username-job-default-3-xplnt* and *username-job-default-2-gtmld* are running in parallel. Once they finish, the job will be completed.

```
kubectl -n username-namespace get pods
```

===
```
NAME                           READY   STATUS      RESTARTS   AGE
username-job-default-1-gm8q2   0/1     Completed   0          103s
username-job-default-0-fz6gl   0/1     Completed   0          103s
username-job-default-3-xplnt   1/1     Running     0          37s
username-job-default-2-gtmld   1/1     Running     0          37s
```
===

### get access to a pod:

```
kubectl exec -n username-namespace --stdin --tty username-job-default-0-78dzg -- /bin/sh
```

### list output data:
> once the job is completed, the output contained in the */data* folder will be stored in the path */kubernetes/nfs/*:

```
ls -lt /kubernetes/nfs/username/pvc-* | grep "username-job-default"
```

===
```
-rw-r--r-- 1 nobody nogroup 0 Oct 20 10:51 username-job-default-2-gtmld.txt
-rw-r--r-- 1 nobody nogroup 0 Oct 20 10:51 username-job-default-3-xplnt.txt
-rw-r--r-- 1 nobody nogroup 0 Oct 20 10:50 username-job-default-1-gm8q2.txt
-rw-r--r-- 1 nobody nogroup 0 Oct 20 10:50 username-job-default-0-fz6gl.txt
```
===

> **Note:** Now, it is time to move all the data to a different location, because once we delete the job, everything will be lost.

---