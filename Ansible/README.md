# Install-K8s-with-Ansible-on-Ubuntu-22.04

## 📝 Table of Contents

- [About](#about)
- [Getting Started](#getting_started)
- [Deployment](#deployment)
- [Usage](#usage)
- [Built Using](#built_using)
- [TODO](../TODO.md)
- [Contributing](../CONTRIBUTING.md)
- [Authors](#authors)
- [Acknowledgments](#acknowledgement)

## 🧐 About <a name = "about"></a>

Write about 1-2 paragraphs describing the purpose of your project.

## Prerequisites

### Ansible
[Install Ansible on Ubuntu](https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html#installing-ansible-on-debian)

### Git

## Quick Start

Step 1: Git Clone 

```
git clone https://github.com/quangnghi99/Hands-on-K8s.git
```

Step 2: Edit [inventory.ini](./inventory.ini) file

Change the number of masters and workers according to your cluster

```
[master]
master1
master2
master3
[worker]
worker1
worker2
worker3
```

Step 3: Run Ansible Playbook

```
ansible-playbook -i inventory.ini site.yml
```
## Installation Components

### Setup Loadbalancer
```
sudo apt update
sudo apt install nginx
mkdir /etc/nginx/k8s-lb.d
cd /etc/nginx/k8s-lb.d
vi apiserver.conf
```

Configure /etc/nginx/apiserver.conf

```
stream {
    upstream kubernetes {
        server master1_ip:6443 max_fails=3 fail_timeout=30s;
        server master2_ip:6443 max_fails=3 fail_timeout=30s;
        server master3_ip:6443 max_fails=3 fail_timeout=30s;
    }
server {
        listen 6443;
        listen 443;
        proxy_pass kubernetes;
    }
}
```

Add /etc/nginx/nginx.conf
```
include /etc/nginx/k8s-lb.d/*
```


### Install Containerd
```
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sudo sysctl --system
sudo apt install containerd -y
mkdir /etc/containerd
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
systemctl restart containerd
```

### Install kubeadm, kubelet, kubectl
```
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

### Init Cluster
```
kubeadm init --control-plane-endpoint=apisever.lb:6443 --upload-certs --pod-network-cidr=10.0.0.0/8
```
### Copy kubeconfig
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
### Install CNI
```
helm repo add cilium https://helm.cilium.io/
helm install cilium cilium/cilium  --set clusterPool.podCIDRs[0]=192.168.0.0/16 --namespace kube-system
```
### Add Node
Create token
```
kubeadm token create
```
Discovery token ca cert hash
```
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | \
openssl dgst -sha256 -hex | sed 's/^.* //'
```
Upload Certificate
```
kubeadm init phase upload-certs --upload-certs
```
#### Add Master Node
```
kubeadm join apiserver.lb:6443 --token [token]--discovery-token-ca-cert-hash sha256:[cert_hash] --control-plane --certificate-key [Certificate]
```
#### Add Worker Node
```
kubeadm join apiserver.lb:6443 --token [token]--discovery-token-ca-cert-hash sha256:[cert_hash]
```

