#!/bin/bash

# Set your GKE cluster name and zone
CLUSTER_NAME="militaryknowledge-cluster"
ZONE="europe-west1-b"

# Fetch the internal IP of the GKE cluster
INTERNAL_IP=$(gcloud container clusters describe $CLUSTER_NAME --zone $ZONE --format='value(privateClusterConfig.privateEndpoint)')

# Output the internal IP
echo $INTERNAL_IP
chmod +x get_internal_ip.sh
./get_internal_ip.sh

