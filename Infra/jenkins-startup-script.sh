#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Update and install dependencies
apt-get update
apt-get install -y openjdk-17-jdk curl apt-transport-https ca-certificates software-properties-common

# Create jenkins user if it doesn't exist
if ! id "jenkins" &>/dev/null; then
    useradd -m -s /bin/bash jenkins
fi

# Add jenkins user to sudoers
echo "support@ctengineering.de ALL=(ALL) NOPASSWD: /bin/su - jenkins" | sudo tee -a /etc/sudoers.d/jenkins

# Install Jenkins
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update package index and install Jenkins
apt-get update
apt-get install -y jenkins

# Ensure Jenkins is running as the jenkins user
sudo sed -i 's/JENKINS_USER=.*/JENKINS_USER=jenkins/' /etc/default/jenkins

# Start and enable Jenkins
systemctl start jenkins
systemctl enable jenkins

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce
usermod -aG docker jenkins

# Install kubectl
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl  # Clean up

# Install Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key --keyring /usr/share/keyrings/hashicorp.gpg add -
echo "deb [signed-by=/usr/share/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
apt-get update
apt-get install -y terraform

# Install Google Cloud SDK
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
apt-get update
apt-get install -y google-cloud-sdk

# Install Helm
curl https://baltocdn.com/helm/signing.asc | sudo apt-key --keyring /usr/share/keyrings/helm.gpg add -
echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
apt-get update
apt-get install -y helm

# Restart Jenkins to apply changes
systemctl restart jenkins