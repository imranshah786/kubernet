# Run a job using a persistent volume:
---

## first, we need to create the job manifest:
> **Note:** do it from the server

### go to the working folder:
``cd ~/kubernetes/jobs/username/default/``

We create the *username-job-yaml* file containing the following terms:

- a **persistent volume claim (pvc)** named *username-pv-claim* of type nfs-csi, that can be mounted as read-write by many nodes, and therefore allows multiple pods to access the volume.

- a **config map** named *avida-config* to provide a bash script file that will execute avida and copy the output */data* folder to the NFS server once avida finishes.

- a **job** named *username-job-default* will run 4 replicates of avida, running 2 in parallel (i.e., at the same time). The pods will use the persistent volumen claim defined as *avida-pv-claims*, to mount the folders */data* (to permanently store the results copied from the */avida/data* folder), and */avida-config* (to provide the customized script file *run-avida.sh* to the container before running it).

We show here how to run 4 replicates of avida, running 2 in parallel. The image (fortunalab/avida:2.14.alpine.default) that will be used by the containers will be downloaded from [our repository in Docker Hub](https://hub.docker.com/r/fortunalab/avida). Each container will run within a single pod and will request at least 200M (max 300M) of RAM and 600 milliseconds (max 800 milliseconds of cpu time (1000 milliseconds is equivalent to 1 core/thread).

---

## second, build a docker image for the job:
> **Note:** we are still in the server

We will run an experiment using avida.

### copy in a folder named *config/* everything that is needed to run the experiment:
> **Note:** the default files of avida will be overwritten

- ``avida.cfg``
    > if you want to overwrite the default file.
 - ``environment.cfg``
    > if you want to limit the amount of resources for hosts. 
 - ``events.cfg``
    > if you want to specify some events over the course of the experiment.

### build a docker image:
> it will use the following Dockerfile to build an Ubuntu image containig *avida* (compiled from our [gitlab repository](https://gitlab.com/fortunalab/avida) and the local *config* folder:

#### Dockerfile

    FROM ubuntu:20.04 as avida-builder
    ARG DEBIAN_FRONTEND=noninteractive
    WORKDIR /gitlab.com/fortunalab/
    RUN apt-get update  && apt-get -y --no-install-recommends install \
        ca-certificates \
        gcc-9 \
        g++-9 \
        cmake=3.16.3-1ubuntu1 \
        make=4.2.1-1.2 \
        git=1:2.25.1-1ubuntu3.5 \
        curl \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 100 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 100 \ 
    && git clone https://gitlab.com/fortunalab/avida.git
    WORKDIR /gitlab.com/fortunalab/avida
    RUN git submodule foreach git fetch
    RUN git submodule update --init --recursive
    RUN git checkout c6179ffc
    RUN ./build_avida

    FROM alpine:3.15.4
    RUN set -x && \
      apk add --no-cache --update \
        libstdc++ \
        gcompat
    WORKDIR /avida/
    COPY --from=avida-builder /gitlab.com/fortunalab/avida/cbuild/work/ .
    ADD config/ .

#### build the image:

``docker build ./ -t fortunalab/avida:2.14.alpine.default``

### list docker images:
``docker images``

### test the experiment before running the job:
#### execute the image in docker:
``docker run -it fortunalab/avida:2.14.alpine.default /bin/sh``

#### export the environment variable as it will happen in Kubernetes:
``export MY_POD_NAME="username-job-default-0-xxx"``

#### execute avida:
``./avida``

#### execute the following command from another terminal to access the same container:

##### first, find out the container ID:
``docker ps``

##### then, access the same container:
``docker exec -it containerID /bin/sh``

##### find out how much memory is used:
``echo $(ps aux | grep /avida | awk '{ print $1 }' | head -n 1) | xargs pmap | tail -n 1``
    
> ... use this information to get a more precise estimate of the RAM required, and specify it in the *username-job-default.yalm* file.

#### exit from the docker image in both terminals:

``exit``

### once we have checked that everything works as it should ...
#### upload the following data to the folder *jobs/username/default/* in our [gitlab remote repository](https://gitlab.com/fortunalab/kubernetes):

- ``config/``
    > the local folder containing the customized configuration files
- ``Dockerfile``
    > so that anyone can build the same docker image (e.g., compile avida at a specific *commit*)
- ``username-job-default.yalm``
    > yalm file to be run in Kubernetes
    
#### upload the image to DockerHub:
``docker push fortunalab/avida:2.14.alpine.default``
    
#### copy the yaml file to the master node:
> **Note:** do it from the master node:

``cd ~/kubernetes/username``

``scp server://~/kubernetes/jobs/username/default/username-job-default.yaml .``

---

## and finally, run the job:
> **Note:** we do it from the master node

> it can also be done by reading the file directly from our [gitlab repository](https://gitlab.com/fortunalab/kubernetes/-/tree/master/jobs) (as shown here)

## as admin:

```
microk8s kubectl apply -f https://gitlab.com/fortunalab/kubernetes/-/raw/master/jobs/username/default/username-job-default.yaml
```

===
```
persistentvolumeclaim/username-pv-claim created
configmap/avida-config created
job.batch/username-job-default created
```
===

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

## as user:
```
kubectl apply -f https://gitlab.com/fortunalab/kubernetes/-/raw/master/jobs/username/default/username-job-default.yaml
```

===
```
persistentvolumeclaim/username-pv-claim created
configmap/avida-config created
job.batch/username-job-default created

```
===

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