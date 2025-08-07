# Use an official base image with Ubuntu
FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install dependencies, Terraform, and kubectl
ARG TERRAFORM_VERSION=1.8.4
ARG KUBECTL_VERSION=$(curl -sL https://dl.k8s.io/release/stable.txt)

RUN apt-get update && \
    apt-get install -y curl unzip gnupg software-properties-common apt-transport-https && \
    \
    # Install Terraform
    curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip && \
    unzip terraform.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform.zip && \
    terraform -v && \
    \
    # Install kubectl
    curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/ && \
    kubectl version --client

