# Docker on Ubuntu 20.04
> master node:
---

## update your existing list of packages:

```
sudo apt-get update
```

## install packages for apt to use packages over HTTPS:

```
sudo apt install apt-transport-https ca-certificates curl software-properties-common
```

## add the GPG key from the Docker repository into your system:

```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```

## add the Docker repository to the APT sources:

```
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
```

### make sure you will install it from the Docker repository instead of the default Ubuntu repository:

```
apt-cache policy docker-ce
```

## install Docker:

```
sudo apt-get install docker-ce
```

### check that Docker is installed and the daemon started (the process should be enabled to start on boot):

```
sudo systemctl status docker
```

## execute Docker without using sudo:

### add your username to the docker group:

```
sudo usermod -aG docker username
```

### apply the new group membership by typing the following:

```
su - username
```

### confirm that your user is now added to the docker group by typing:

```
groups
```

## create a tar file of a docker image for sharing:

### compress image and export:

```
docker save imagename:latest | gzip > imagename.tar.gz
```

### copy file to remote machine:

```
scp imagename.tar.gz username@machine:/home/username/
```

### decompress file in remote machine:

```
gunzip imagename.tar.gz
```

### load docker image:

```
docker load -i imagename.tar
```

---