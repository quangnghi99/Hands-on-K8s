#!/bin/bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm search repo minio
helm pull bitnami/minio --version=11.2.10
tar -xzf minio-11.2.10.tgz
cp minio/values.yaml  values-minio.yaml