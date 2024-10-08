#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

echo "Starting Jenkins installation..."

# Update and install dependencies
sudo apt-get update
sudo apt-get install -y openjdk-17-jdk curl apt-transport-https ca-certificates software-properties-common gnupg2 lsb-release

# Create jenkins user if it doesn't exist
if ! id "jenkins" &>/dev/null; then
    useradd -m -s /bin/bash jenkins
fi

# Add jenkins user to sudoers
sudo echo "support@ctengineering.de ALL=(ALL) NOPASSWD: /bin/su - jenkins" | sudo tee /etc/sudoers.d/jenkins
chmod 440 /etc/sudoers.d/jenkins  # Ensure correct permissions for sudoers file

# Install Jenkins
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update package index and install Jenkins
sudo apt-get update
sudo apt-get install -y jenkins

# Ensure Jenkins is running as the jenkins user
sudo sed -i 's/JENKINS_USER=.*/JENKINS_USER=jenkins/' /etc/default/jenkins

# Start and enable Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /usr/share/keyrings/docker-archive-keyring.gpg > /dev/null
add-apt-repository "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce
usermod -aG docker jenkins

# Install kubectl
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl  # Clean up

# Install Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
sudo apt-get update
sudo apt-get install -y terraform

# Install Google Cloud SDK
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list > /dev/null
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo tee /usr/share/keyrings/cloud.google.gpg > /dev/null
sudo apt-get update
sudo apt-get install -y google-cloud-sdk

# Install Helm
curl https://baltocdn.com/helm/signing.asc | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list > /dev/null
sudo apt-get update
sudo apt-get install -y helm

# Restart Jenkins to apply changes
systemctl restart jenkins
