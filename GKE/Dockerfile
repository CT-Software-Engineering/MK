# Use a lightweight base image
FROM alpine:3.16

# Install required packages: curl for downloading Helm, and bash for scripting
RUN apk add --no-cache curl bash

# Set Helm version to install
ENV HELM_VERSION="v3.11.2"

# Download and install Helm
RUN curl -LO https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz && \
    tar -zxvf helm-${HELM_VERSION}-linux-amd64.tar.gz && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    chmod +x /usr/local/bin/helm && \
    rm -rf linux-amd64 helm-${HELM_VERSION}-linux-amd64.tar.gz

# Install kubectl for interacting with GKE
RUN apk add --no-cache kubectl

# Set the default entrypoint
ENTRYPOINT ["helm"]

# You can add any additional helm or kubectl commands you want to run here

