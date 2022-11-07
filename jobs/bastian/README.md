# Workflow to execute a job using Kubernetes.
---

## go to the working folder:
cd ~/nextcloud/projects/projects@ongoing/kubernetes/avida-experiments/bastian

## copy to the local folder *data/* everything that is needed to run the experiment:
 - ``ancestor@hosts``
    > folder containing the hosts that will be used as ancestors.
 - ``ancestor@parasites``
    > folder containing the parasites that will be used as ancestors.
- ``avida.cfg``
    > required to overwrite the default file: it specifies the *instset-transsmt.cfg* file to work with parasites.
 - ``environment.cfg``
    > limited resources for hosts. 
 - ``events.cfg``
    > ancestors will be specified following the content of the *run-avida.sh* script.
 - ``generation_time_hosts.csv``
    > used to specify how long the experiment will last.
 - ``input.csv``
    > used to get a different pair of ancestors.
 - ``instset-transsmt.cfg``
    > required to work with parasites. 
 - ``run-avida.sh``
    > bash script that will run avida and store the results
    
    > **Note:** replace first line: !#/bin/bash by !#/bin/sh.
---

## build a docker image:
> it will use the Dockerfile to build an Ubuntu image containig *avida* and the local *data* folder

``docker build ./ -t fortunalab/avida:2.15.alpine.coevo-genome-size``

## list docker images
``docker images``

---
## test the experiment before running the job:
### execute the image in docker:
``docker run -it fortunalab/avida:2.15.alpine.coevo-genome-size /bin/sh``

### export the environment variable as it will happen in Kubernetes:
``export MY_POD_NAME="bastian-job-coevo-genome-size-0-xxx"``

### execute the bash script:
#### first, make it executable:
``chmod 770 run-avida.sh``

#### then, run it:
``./run-avida.sh``

### execute the following command from another terminal to access the same container:

#### first, find out the container ID:
``docker ps``

#### then, access the same container:
``docker exec -it containerID /bin/sh``

#### find out how much memory is used:
``echo $(ps aux | grep /avida | awk '{ print $1 }' | head -n 1) | xargs pmap | tail -n 1``
    
> ... use this information to get a more precise estimate of the RAM required, and specify it in the *bastian-job-coevo-genome-size.yalm* file.

#### exit from the docker image in both terminals:

``exit``

---

## once we have checked that everything works as it should ...
### upload the following data to our [remote repository](https://gitlab.com/fortunalab/kubernetes) in gitlab:

- ``data/``
    > the local folder containing the data
- ``Dockerfile``
    > to allow anyone build the same docker image
- ``bastian-job-coevo-genome-size.yalm``
    > yalm file to be run in kubernetes
- ``README.md``
    > current file
    
### upload the image to DockerHub:
``docker push fortunalab/avida:2.15.alpine.coevo-genome-size``
    
### cp yaml file to the master node:
> **Note:** do it from sancho:

``cd ~/kubernetes/bastian``

``scp quijote://~/nextcloud/projects/projects@ongoing/kubernetes/avida-experiments/bastian/bastian-job-coevo-genome-size.yaml .``

### finally, go to sancho an run the job in Kubernetes:
kubectl apply -f avida-job-coevo-genome-size.yaml

---