#!/bin/bash

BUCKET_NAME=$1
CLUSTER_NAME=$2
AWS_REGION=$3
GIT_ACTOR=$4
ACTION=$5

cat <<EOF > /root/iti-eks/terraform/platform/backend.tf
terraform {
    backend "s3" {
        bucket = "${BUCKET_NAME}"
        key    = "terraform/state/infra-platform"
        region = "${AWS_REGION}"
    }
}
EOF

cat <<EOF > /root/iti-eks/terraform/platform/vars.tfvars
bucket = "${BUCKET_NAME}"
repo   = "https://github.com/${GIT_ACTOR}/iti-eks-gitops-capstone"
domain_name="danielfarag.cloud"
cert-email="danielfarag146@gmail.com"
EOF

aws eks --region ${AWS_REGION} update-kubeconfig --name ${CLUSTER_NAME}

terraform -chdir=/root/iti-eks/terraform/platform init > /root/logs-platform-tf-init 2> /root/logs-platform-tf-init-errors

terraform -chdir=/root/iti-eks/terraform/platform ${ACTION} -var-file=vars.tfvars -auto-approve > /root/logs-platform-tf-${ACTION} 2> /root/logs-platform-tf-${ACTION}-errors