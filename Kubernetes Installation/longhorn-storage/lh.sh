#!/bin/bash
pvcreate /dev/vdb
vgcreate data /dev/vdb
lvcreate -l 100%FREE -n data data
mkdir -p /data/longhorn-storage
mkfs.xfs /dev/data/data
mount /dev/data/data /data
echo "/dev/data/data /data xfs defaults 0 0" | sudo tee -a /etc/fstab