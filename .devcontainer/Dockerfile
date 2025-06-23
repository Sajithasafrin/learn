# Use an official base image with Ubuntu
FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install dependencies and Terraform
ARG TERRAFORM_VERSION=1.8.1

RUN apt-get update && \
    apt-get install -y curl unzip gnupg software-properties-common && \
    curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip && \
    unzip terraform.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform.zip && \
    terraform -v
