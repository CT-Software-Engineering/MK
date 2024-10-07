terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
  }
}



provider "kubernetes" {
  config_path = "/home/jenkins/.kube/config"
  config_context = "gke_militaryknowledge_europe-west1-b_militaryknowledge-cluster"
   host                   = "https://10.0.2.60"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.your_cluster.master_auth[0].cluster_ca_certificate)
}
data "google_client_config" "default" {}



resource "kubernetes_namespace" "neo4j" {
  metadata {
    name = "neo4j"
  }
}

resource "kubernetes_secret" "neo4j_secrets" {
  metadata {
    name      = "neo4j-secrets"
    namespace = kubernetes_namespace.neo4j.metadata[0].name
  }

  data = {
    NEO4J_AUTH = "neo4j/${var.neo4j_password}"
    "client.crt" = var.client_certificate
    
  }
}

resource "kubernetes_persistent_volume" "neo4j_pv" {
  metadata {
    name = "neo4j-pv"
  }

  spec {
    capacity = {
      storage = "10Gi" # Adjust size as needed
    }
    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/data/neo4j" # Change this to your desired host path if needed
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "neo4j_pvc" {
  metadata {
    name      = "neo4j-pvc"
    namespace = kubernetes_namespace.neo4j.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi" # Should match the PersistentVolume size
      }
    }
  }
}

resource "kubernetes_deployment" "neo4j" {
  metadata {
    name      = "neo4j"
    namespace = kubernetes_namespace.neo4j.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "neo4j"
      }
    }

    template {
      metadata {
        labels = {
          app = "neo4j"
        }
      }

      spec {
        container {
          image = "neo4j:4.4"
          name  = "neo4j"

          port {
            container_port = 7474
            name           = "http"
          }
          port {
            container_port = 7687
            name           = "bolt"
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.neo4j_secrets.metadata[0].name
            }
          }

          volume_mount {
            name       = "neo4j-data"
            mount_path = "/data" # Neo4j stores its data here
          }
        }

        volume {
          name = "neo4j-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.neo4j_pvc.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "neo4j" {
  metadata {
    name      = "neo4j"
    namespace = kubernetes_namespace.neo4j.metadata[0].name
  }

  spec {
    selector = {
      app = kubernetes_deployment.neo4j.spec[0].template[0].metadata[0].labels.app
    }
    port {
      port        = 7474
      target_port = 7474
      name        = "http"
    }
    port {
      port        = 7687
      target_port = 7687
      name        = "bolt"
    }
    type = "ClusterIP" # Change this if you need a different service type
  }
}
