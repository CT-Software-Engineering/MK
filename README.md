# GKEMilitary
# this template will build a Ubuntu Jenkins Server in a new VPC with one public subnet (can be increased if needed)
no nat gateway has been created for Infrastructure there is however one in the GKE folder which builds the GKE Cluster.
the Jenkins-Server is configured to connect to Github for CICD pipeline with SSH. 
The SSH setup process is as follows:
To set up a CI/CD pipeline from Jenkins to GitHub using SSH, you'll need to install and configure several Jenkins plugins. Here's a list of the essential plugins and some optional ones that can enhance your workflow: [1]

# API Services that need to be enabled in GCP:
1. GKE Cluster Communication
Kubernetes Engine API: Required for creating and managing GKE clusters.
2. Jenkins Server Communication
Compute Engine API: If Jenkins is running on Compute Engine, this API will be necessary for any interactions with VM instances.
Cloud Storage API: If you need to store artifacts or logs in Google Cloud Storage.
Cloud Pub/Sub API: If you are using Pub/Sub for messaging between Jenkins and other services.
Cloud SQL: Google Cloud SQL is a hosted and fully managed relational database service on Google's infrastructure.
3. Database Connectivity
Cloud SQL API: If you are using Cloud SQL for your databases, this API is essential for managing and connecting to your Cloud SQL instances.
Firestore API: If you are using Firestore as your database.
BigQuery API: If you need to connect to BigQuery for data analytics.
4. Additional Services
Identity and Access Management (IAM) API: To manage permissions related to your services.
Service Management API: To manage and monitor your services.
5. Database Migration API:Manage Cloud Database Migration Service resources on Google Cloud Platform.



# Essential plugins:

Git plugin

This is the core plugin for Git integration in Jenkins. [2]

It allows Jenkins to clone repositories and interact with Git.

GitHub plugin

Provides deeper integration with GitHub, including webhook support.

Credentials plugin

Manages credentials for various purposes, including SSH keys.

SSH Credentials plugin

Allows you to store SSH private keys in Jenkins for authentication. [3]

Optional but recommended plugins:

Pipeline plugin

Supports creating pipelines as code, which is a modern best practice for CI/CD.

GitHub Branch Source plugin

Automatically discovers branches and pull requests from GitHub.

Blue Ocean plugin

Provides a modern, visual interface for Jenkins pipelines.

Workspace Cleanup plugin

Helps keep your Jenkins workspace clean between builds.

To install these plugins:

Go to "Manage Jenkins" > "Manage Plugins"

Go to the "Available" tab

Search for each plugin and check the box next to it

Click "Install without restart" at the bottom of the page

After installation, you'll need to configure Jenkins to use SSH for GitHub:

Generate an SSH key pair if you haven't already.

Add the public key to your GitHub account.

In Jenkins, go to "Manage Jenkins" > "Manage Credentials"

Add a new credential of type "SSH Username with private key"

Paste your private key into the appropriate field.

Then, when setting up your Jenkins job or pipeline:

Use the Git plugin to specify your repository URL (use the SSH URL from GitHub).

Select the SSH credential you created for authentication.