#!/bin/bash

BUCKET_NAME=$1
CLUSTER_NAME=$2
AWS_REGION=$3
GIT_ACTOR=$4
ACTION=$5
GIT_TOKEN=$6

cat <<EOF > /root/iti-eks/terraform/manifests/backend.tf
terraform {
    backend "s3" {
        bucket = "${BUCKET_NAME}"
        key    = "terraform/state/infra-manifests"
        region = "${AWS_REGION}"
    }
}
EOF

cat <<EOF > /root/iti-eks/terraform/manifests/vars.tfvars
bucket = "${BUCKET_NAME}"
repo   = "https://github.com/${GIT_ACTOR}/iti-eks-gitops-capstone"
github_name="${GIT_ACTOR}"
github_token="${GIT_TOKEN}"

EOF


aws eks --region ${AWS_REGION} update-kubeconfig --name ${CLUSTER_NAME}

terraform -chdir=/root/iti-eks/terraform/manifests init > /root/logs-manifests-tf-init 2> /root/logs-manifests-tf-init-errors

terraform -chdir=/root/iti-eks/terraform/manifests ${ACTION} -var-file=vars.tfvars -auto-approve > /root/logs-manifests-tf-${ACTION} 2> /root/logs-manifests-tf-${ACTION}-errors