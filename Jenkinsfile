pipeline {
    agent any
    environment {
        GCP_PROJECT_ID = 'militaryknowledge'
        GKE_CLUSTER_NAME = 'my-gke-cluster'
        GKE_CLUSTER_ZONE = 'europe-west1-b'
        GITHUB_CREDENTIALS_ID = '92229892-c431-4b3b-927f-6e43e5be5946'
        GCP_CREDENTIALS_ID = 'b20451ad-020d-4043-8f19-a8b4aede503c'
    }
    stages {
        stage('Deploy to GCP') {
            steps {
                script {
                    def envName = env.BRANCH_NAME
                    if (envName == 'development') {
                        // Deploy to development environment
                    } else if (envName == 'staging') {
                        // Deploy to staging environment
                    } else if (envName == 'production') {
                        // Deploy to production environment
                    }
                }
            }
        }

        stage('Checkout SCM') {
            steps {
                script {
                    checkout scmGit(branches: [[name: '*/main']],
                                    extensions: [],
                                    userRemoteConfigs: [[url: 'https://github.com/CT-Software-Engineering/MK.git', credentialsId: "${GITHUB_CREDENTIALS_ID}"]])
                }
            }
        }

        stage("Authenticate to GCP") {
            steps {
                script {
                    try {
                        withCredentials([file(credentialsId: "${GCP_CREDENTIALS_ID}", variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                            sh "echo 'GITHUB_CREDENTIALS_ID is set to: ${GITHUB_CREDENTIALS_ID}'"
                            sh "if [ -f \"${GOOGLE_APPLICATION_CREDENTIALS}\" ]; then echo 'GCP key file exists'; else echo 'GCP key file does not exist'; fi"
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

        stage('Initializing Terraform') {
            steps {
                script {
                    dir('GKE') {
                        sh 'terraform init'
                    }
                }
            }
        }

        stage('Formatting Terraform Code') {
            steps {
                script {
                    dir('GKE') {
                        sh 'terraform fmt -recursive'
                    }
                }
            }
        }

        stage('Validating Terraform') {
            steps {
                script {
                    dir('GKE') {
                        sh 'terraform validate'
                    }
                }
            }
        }

        stage('Previewing the Infrastructure') {
            steps {
                script {
                    dir('GKE') {
                        sh 'terraform plan'
                        // input(message: "Are you sure to proceed?", ok: "proceed")
                    }
                }
            }
        }

        stage('Refresh Terraform State') {
            steps {
                script {
                    dir('GKE') {
                        sh 'terraform refresh'
                    }
                }
            }
        }

        stage('Creating/Destroying a GKE Cluster') {
            steps {
                script {
                    dir('GKE') {
                        // sh 'terraform $action --auto-approve'
                        sh 'terraform apply --auto-approve'
                        // sh 'terraform destroy --auto-approve'
                    }
                }
            }
        }

        stage('Initialize Terraform - GraphDB') {
            steps {
                script {
                    dir('GKE/DB/graphdb') {
                        sh 'terraform init'
                    }
                }
            }
        }

        stage('Apply Terraform - GraphDB') {
            steps {
                script {
                    dir('GKE/DB/graphdb') {
                        sh 'terraform apply --auto-approve'
                    }
                }
            }
        }

        stage('Initialize Terraform - PostgreSQL') {
            steps {
                script {
                    dir('GKE/DB/postgresql') {
                        sh 'terraform init'
                    }
                }
            }
        }

        stage('Apply Terraform - PostgreSQL') {
            steps {
                script {
                    dir('GKE/DB/postgresql') {
                        sh 'terraform apply --auto-approve'
                    }
                }
            }
        }

        stage('Post-Deployment Verification') {
            steps {
                script {
                    // Optional: Add verification steps if needed, e.g., checking DB connection.
                }
            }
        }
    }
}
