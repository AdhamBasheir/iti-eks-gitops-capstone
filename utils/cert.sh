#!/bin/bash

BUCKET_NAME=$1
CLUSTER_NAME=$2
AWS_REGION=$3
ACTION=$4

cat <<EOF > /root/iti-eks/terraform/certmanager/backend.tf
terraform {
    backend "s3" {
        bucket = "${BUCKET_NAME}"
        key    = "terraform/state/infra-certbot"
        region = "${AWS_REGION}"
    }
}
EOF


aws eks --region ${AWS_REGION} update-kubeconfig --name ${CLUSTER_NAME}

terraform -chdir=/root/iti-eks/terraform/certmanager init > /root/logs-certmanager-tf-init 2> /root/logs-certmanager-tf-init-errors

terraform -chdir=/root/iti-eks/terraform/certmanager ${ACTION} -auto-approve > /root/logs-certmanager-tf-${ACTION} 2> /root/logs-certmanager-tf-${ACTION}-errors