<h3 align="center">LongHorn-Storage</h3>

---
## 📝 Table of Contents

- [📝 Table of Contents](#-table-of-contents)
- [🧐 About ](#-about-)
- [🏁 Getting Started ](#-getting-started-)
  - [Prerequisites](#prerequisites)
  - [Installing](#installing)
- [🔧 Running the tests ](#-running-the-tests-)
  - [Delete Storage Class](#delete-storage-class)
  - [Retain Storage Class](#retain-storage-class)
- [🎈 Create Pod using Longhorn ](#-create-pod-using-longhorn-)
- [🎉 Acknowledgements ](#-acknowledgements-)

## 🧐 About <a name = "about"></a>

Install Longhorn Storage on K8s Cluster

## 🏁 Getting Started <a name = "getting_started"></a>
### Prerequisites

Helm

Kubernetes Cluster: A running Kubernetes cluster (v1.21 or later is recommended).

Storage Requirements: Ensure the cluster nodes have at least one disk for Longhorn storage.

```
sudo mkdir -p /data/longhorn-storage
```
Make sure open-iscsi is installed on the worker
```
sudo apt install open-iscsi -y
sudo systemctl status iscsid
```
### Installing

<b>Step 1: Add the Longhorn Helm Chart Repository</b>
Add the official Longhorn Helm repository to your Helm CLI:

```
helm repo add longhorn https://charts.longhorn.io
helm repo update
helm search repo longhorn
```

<b>Step 2: Choose Longhorn version </b>

```
# helm search repo longhorn
NAME                    CHART VERSION   APP VERSION     DESCRIPTION                                       
longhorn/longhorn       1.7.2           v1.7.2          Longhorn is a distributed block storage system ...
```
<b>Step 3: Pull Longhorn Using Helm</b>
```
helm pull longhorn/longhorn --version 1.7.2
tar -xzf longhorn-1.7.2.tgz 
```
<b>Step 4: Copy helmchart's default value file to customize it according to your environment:</b>
```
cp longhorn/values.yaml values-longhorn.yaml
```
Edit the values-longhorn.yaml file and update parameters:
```
defaultDataPath: /data/longhorn-storage/
replicaSoftAntiAffinity: true
storageMinimalAvailablePercentage: 15
upgradeChecker: false
defaultReplicaCount: 2
backupstorePollInterval: 500
nodeDownPodDeletionPolicy: do-nothing
guaranteedEngineManagerCPU: 15
guaranteedReplicaManagerCPU: 15

ingress:  
  enabled: true
  ingressClassName: <your-ingress-classname>
  host: <your-longhorn-ui-domain>

namespaceOverride: "storage"
```

<b>Step 5: Install Longhorn Storage </b>
```
helm install longhorn-storage -f values-longhorn.yaml longhorn --namespace storage
```
Check the created pods
```
# kubectl -n storage get pods
NAME                                                     READY   STATUS    RESTARTS      AGE
csi-attacher-698944d5b-9hsw6                             1/1     Running   0             93m
csi-attacher-698944d5b-b5rn7                             1/1     Running   0             93m
csi-attacher-698944d5b-vcfl8                             1/1     Running   1 (92m ago)   93m
csi-provisioner-b98c99578-65zlv                          1/1     Running   0             93m
csi-provisioner-b98c99578-7djg4                          1/1     Running   0             93m
csi-provisioner-b98c99578-h58c6                          1/1     Running   0             93m
csi-resizer-7474b7b598-5n8ft                             1/1     Running   0             93m
csi-resizer-7474b7b598-rbznw                             1/1     Running   0             93m
csi-resizer-7474b7b598-x9qkz                             1/1     Running   0             93m
csi-snapshotter-774467fdc7-2s276                         1/1     Running   0             93m
csi-snapshotter-774467fdc7-x9q57                         1/1     Running   0             93m
csi-snapshotter-774467fdc7-xfrhq                         1/1     Running   0             93m
engine-image-ei-51cc7b9c-62fmp                           1/1     Running   0             94m
engine-image-ei-51cc7b9c-6z9wl                           1/1     Running   0             94m
engine-image-ei-51cc7b9c-qpj4g                           1/1     Running   0             94m
instance-manager-735570128bc29f425c92069e2847503c        1/1     Running   0             93m
instance-manager-b7ae997b4b50a3e3d89c4b6357e2dd7b        1/1     Running   0             93m
instance-manager-d3e34ae08da975ede7ab5584cb305d69        1/1     Running   0             93m
longhorn-csi-plugin-6t5lx                                3/3     Running   1 (92m ago)   93m
longhorn-csi-plugin-c55hg                                3/3     Running   0             93m
longhorn-csi-plugin-ffrz4                                3/3     Running   1 (92m ago)   93m
longhorn-driver-deployer-d4cd67756-8cpn7                 1/1     Running   0             94m
longhorn-manager-5ndnm                                   2/2     Running   0             94m
longhorn-manager-nwpgx                                   2/2     Running   0             94m
longhorn-manager-rzlmv                                   2/2     Running   0             94m
longhorn-ui-c867d449f-qzjp9                              1/1     Running   0             94m
longhorn-ui-c867d449f-ztwx2                              1/1     Running   0             94m
share-manager-pvc-2f17809d-26b3-476c-ac4e-049d0704b40c   1/1     Running   0             49m
```

## 🔧 Running the tests <a name = "tests"></a>

Create 2 Storage Class: Retain and Delete

### Delete Storage Class

longhorn-storageclass-delete.yaml

```
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: longhorn-storage-delete
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: driver.longhorn.io
allowVolumeExpansion: true
reclaimPolicy: Delete
volumeBindingMode: Immediate
parameters:
  numberOfReplicas: "2"
  staleReplicaTimeout: "2880"
  fromBackup: ""
  fsType: "ext4"
```
### Retain Storage Class
longhorn-storageclass-retain.yaml
```
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: longhorn-storage-retain
provisioner: driver.longhorn.io
allowVolumeExpansion: true
reclaimPolicy: Retain
volumeBindingMode: Immediate
parameters:
  numberOfReplicas: "2"
  staleReplicaTimeout: "2880"
  fromBackup: ""
  fsType: "ext4"
```
```
# kubectl get sc
NAME                                PROVISIONER          RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
longhorn (default)                  driver.longhorn.io   Delete          Immediate           true                   25h
longhorn-static                     driver.longhorn.io   Delete          Immediate           true                   25h
longhorn-storage-delete (default)   driver.longhorn.io   Delete          Immediate           true                   24h
longhorn-storage-retain             driver.longhorn.io   Retain          Immediate           true                   24h
```
## 🎈 Create Pod using Longhorn <a name="usage"></a>

```
      volumeMounts:
        - name: longhorn-pvc-delete # This is the name of the volume we set at the pod level
          mountPath: /var/simple # Where to mount this directory in our container
```

## 🎉 Acknowledgements <a name = "acknowledgement"></a>
- [References](https://viblo.asia/p/k8s-phan-4-cai-dat-storage-cho-k8s-dung-longhorn-1Je5EAv45nL)


[def]: #-table-of-contents