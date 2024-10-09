#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Redirect output to a log file in the home directory
LOGFILE=~/jenkins-startup.log
exec > >(tee -a $LOGFILE) 2>&1  # Redirect all output to a log file

echo "Starting Jenkins installation..."

# Update and install dependencies
sudo apt-get update
sudo apt-get install -y openjdk-17-jdk curl apt-transport-https ca-certificates software-properties-common gnupg2 lsb-release

# Add missing GPG keys for HashiCorp and Google Cloud
echo "Adding GPG keys..."

# HashiCorp GPG key
if ! sudo gpg --list-keys | grep -q "AA16FCBCA621E701"; then
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
else
    echo "HashiCorp GPG key already exists."
fi

# Google Cloud SDK GPG key
if ! sudo gpg --list-keys | grep -q "C0BA5CE6DC6315A3"; then
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
else
    echo "Google Cloud SDK GPG key already exists."
fi

# Update package list and install Terraform and Google Cloud SDK
sudo apt-get update
sudo apt-get install -y terraform google-cloud-sdk

# Create jenkins user if it doesn't exist
if ! id "jenkins" &>/dev/null; then
    sudo useradd -m -s /bin/bash jenkins
fi

# Add jenkins user to sudoers
echo "support@ctengineering.de ALL=(ALL) NOPASSWD: /bin/su - jenkins" | sudo tee /etc/sudoers.d/jenkins
sudo chmod 440 /etc/sudoers.d/jenkins  # Ensure correct permissions for sudoers file

# Install Jenkins
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo gpg --dearmor -o /usr/share/keyrings/jenkins-keyring.asc
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list

# Update package index and install Jenkins
sudo apt-get update
sudo apt-get install -y jenkins

# Ensure Jenkins is running as the jenkins user
sudo sed -i 's/JENKINS_USER=.*/JENKINS_USER=jenkins/' /etc/default/jenkins

# Start and enable Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Install Docker
sudo apt-get update
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the stable Docker repository
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package list and install Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Install kubectl
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl  # Clean up

# Install Helm
curl https://baltocdn.com/helm/signing.asc | sudo gpg --dearmor -o /usr/share/keyrings/helm.gpg
echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list > /dev/null

# Update package index and install Helm
sudo apt-get update
sudo apt-get install -y helm

# Restart Jenkins to apply changes
sudo systemctl restart jenkins

echo "Jenkins installation completed."
