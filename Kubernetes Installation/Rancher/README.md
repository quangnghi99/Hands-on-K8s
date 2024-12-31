# Rancher

## Table of Contents

- [Rancher](#rancher)
  - [Table of Contents](#table-of-contents)
  - [About ](#about-)
  - [Prerequisites](#prerequisites)
    - [Installing](#installing)

## About <a name = "about"></a>

Install Rancher to manage K8s Cluster 

## Prerequisites

Install [Docker](https://docs.docker.com/engine/install/ubuntu/) 

```
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install Lastest version:
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### Installing

Install Rancher with Docker

```
docker run --name rancher-server -d --restart=unless-stopped -p 6860:80 -p 6868:443 --privileged rancher/rancher

```

Sign in and import cluster. Then run on master 1 to join Cluster , example

```
curl --insecure -sfL https://192.168.0.100:6868/v3/import/d6mqd55wnz7vh8ltfg4xvgnfhhmdvmdzxs5m6b24znl5chwjgd977q_c-p4rh9.yaml |kubectl apply -f -

```
