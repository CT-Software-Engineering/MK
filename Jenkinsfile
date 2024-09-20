pipeline {
    agent any
    environment {
    
    GCP_PROJECT_ID = 'militaryknowledge'
    GKE_CLUSTER_NAME = 'my-gke-cluster'
    GKE_CLUSTER_ZONE = 'europe-west1-b'
    GITHUB_CREDENTIALS_ID = '5b5a0dd1-d752-4ff7-ba16-2dc770a89b74' // Add this line
    GCP_CREDENTIALS_ID = 'a5c5c430-c2dc-4a9b-a07d-5e5c34007b90' // Add new GCP credentials ID
    GOOGLE_APPLICATION_CREDENTIALS = credentials('a5c5c430-c2dc-4a9b-a07d-5e5c34007b90')

    }
    stages {
        stage('Checkout SCM') {
            steps {
                script {
                    checkout scmGit(branches: [[name: '*/main']],
                                    extensions: [],
                                    userRemoteConfigs: [[url: 'git@github.com:CT-Software-Engineering/MK.git', credentialsId: "${GITHUB_CREDENTIALS_ID}"]])
                }
            }
        }
        stage("Authenticate to GCP") {
    steps {
        script {
            try {
                withCredentials([file(credentialsId: "${GCP_CREDENTIALS_ID}", variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                    sh "echo 'GITHUB_CREDENTIALS_ID is set to: ${GITHUB_CREDENTIALS_ID}'"
                    sh "if [ -f \"${GITHUB_CREDENTIALS_ID}\" ]; then echo 'GCP key file exists'; else echo 'GCP key file does not exist'; fi"
                    sh "gcloud auth activate-service-account --key-file=${GOOGLE_APPLICATION_CREDENTIALS}"
                    sh "gcloud config set project ${GCP_PROJECT_ID}"
                    sh "gcloud auth list"
                }
            } catch (Exception e) {
                echo "An error occurred during GCP authentication: ${e.getMessage()}"
                currentBuild.result = 'FAILURE'
                error("GCP authentication failed")
            }
        }
    }
}



         stage('Initializing Terraform'){
            steps{
                script{
                    dir('GKE'){
                         sh 'terraform init'
                    }
                }
            }
        }
        stage('Formating terraform code'){
            steps{
                script{
                    dir('GKE'){
                         sh 'terraform fmt -recursive'
                    }
                }
            }
        }
        stage('Validating Terraform'){
            steps{
                script{
                    dir('GKE'){
                         sh 'terraform validate'
                    }
                }
            }
        }
        stage('Previewing the infrastructure'){
            steps{
                script{
                    dir('GKE'){
                         sh 'terraform plan'
                    }
                    //input(message: "Are you sure to proceed?", ok: "proceed")
                }
            }
        }
        stage('Creating/Destroying an GKE cluster'){
            steps{
                script{
                    dir('GKE'){
                         //sh 'terraform $action --auto-approve'
                         //sh 'terraform apply --auto-approve'
                         sh 'terraform destroy --auto-approve'
                    }
                }
            }
        }
/*

        stage('Disable Deletion Protection and Update GKE Cluster') {
    steps {
        script {
            // Install required Python library
            sh 'pip install google-cloud-container'

            // Create and run Python script
            writeFile file: 'disable_deletion_protection.py', text: '''
                # Python script content here
            '''
            sh 'python disable_deletion_protection.py'

            // Refresh Terraform state
            dir('GKE') {
                sh 'terraform refresh'
            }

            // Apply Terraform changes
            dir('GKE') {
                sh 'terraform apply --auto-approve'
            }
        }
    }
}
        stage('Initializing Helm') {
            steps {
                script {
                    sh 'helm repo add bitnami https://charts.bitnami.com/bitnami'
                    sh 'helm repo update'
                }
            }
        }
        
        stage('Check Helm Installation') {
            steps {
                script {
                    try {
                        def helmVersion = sh(script: 'helm version --short', returnStdout: true).trim()
                        echo "Helm is installed. Version: ${helmVersion}"
                    } catch (Exception e) {
                        echo "Helm is not installed or not in PATH"
                        error("Helm check failed: ${e.message}")
                    }
                }
            }
        }
        stage('Update Kubeconfig') {
            steps {
                script {
                    sh 'aws eks update-kubeconfig --name mk --kubeconfig "/var/lib/jenkins/workspace/mk/.kube/config"'
                }
            }
        }

        stage('Deploying Jenkins') {
            steps {
                script {
                    //sh 'helm upgrade jenkins bitnami/jenkins --namespace mk --create-namespace --kubeconfig "/var/lib/jenkins/workspace/mk/.kube/config"'
                    sh 'helm install j
                    enkins bitnami/jenkins --namespace mk --create-namespace --kubeconfig "/var/lib/jenkins/workspace/mk/.kube/config"'
                    //sh 'helm uninstall jenkins bitnami/jenkins --namespace mk --create-namespace --kubeconfig "/var/lib/jenkins/workspace/mk/.kube/config"'
                    
                }
            }
        }

        stage('Verify Jenkins Deployment') {
            steps {
                script {
                    sh 'kubectl get pods -n mk --kubeconfig "$KUBECONFIG"'
                    sh 'kubectl get svc -n mk --kubeconfig "$KUBECONFIG"'
                }
            }
        }

        stage("Deploying Nginx"){
            steps{
                script{
                    withCredentials([file(credentialsId: "${GITHUB_CREDENTIALS_ID}", variable: 'GITHUB_CREDENTIALS_ID')]) {
                    sh "gcloud auth activate-service-account --key-file=${GITHUB_CREDENTIALS_ID}"
                    sh "gcloud config set project militaryknowledge"
                    dir('GKE/configuration-files'){
                    sh "gcloud container clusters get-credentials ${GKE_CLUSTER_NAME} --zone ${GKE_CLUSTER_ZONE} --project ${GCP_PROJECT_ID}"
                    sh 'kubectl apply -f deployment.yml --validate=false'
                    sh 'kubectl apply -f service.yml --validate=false'
                }
             }
        }
        */
    }
}

