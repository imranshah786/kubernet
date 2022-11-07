# Modifying a running job:
## write down what selector and labels used by the job:

``kubectl get job username-default-job -o yaml``

===
```
...
spec:
  backoffLimit: 4
  completionMode: Indexed
  completions: 500
  parallelism: 100
  selector:
    matchLabels:
      controller-uid: 7361739c-829a-4e7b-9c7f-1dc593182440
  suspend: false
  template:
    metadata:
      labels:
        controller-uid: 7361739c-829a-4e7b-9c7f-1dc593182440
        job-name: username-default-job
    spec:
...
```
===

## delete the job but leave its pods running:

``kubectl delete jobs/bastian-job --cascade=orphan``

## create a new job and specify the same selector and labels:
> add also the desired modifications (e.g., duplicate the number of pods running in parallel) in the *username-default-updated-job.yaml* file:

```
apiVersion: batch/v1
kind: Job
metadata:
  name: username-default-updated-job
  namespace: username-namespace
spec:
  completionMode: Indexed
  completions: 500
  parallelism: 200
  manualSelector: true
  selector:
    matchLabels:
      controller-uid: 7361739c-829a-4e7b-9c7f-1dc593182440
  template:
    metadata:
      labels:
        controller-uid: 7361739c-829a-4e7b-9c7f-1dc593182440
        job-name: username-default-job
    spec:
...
```

> Since the existing pods have label controller-uid: 7361739c-829a-4e7b-9c7f-1dc593182440, they are controlled by job *username-default-job* as well.
> The new job will have a different uid, but setting ``manualSelector: true`` tells the system that we know what we are doing and to allow this mismatch.

## run the new job:

``kubectl apply -f username-default-job.yaml``