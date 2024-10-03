terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  host                   = "https://${var.kubernetes_host}"
  token                  = var.kubernetes_token
  cluster_ca_certificate = file("/etc/ssl/certs/ca-certificates.crt")
  
}

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
            mount_path = "/data"
          }
        }

        volume {
          name = "neo4j-data"
          empty_dir {}
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
  }
}
locals {
  kubernetes_ca_cert = file("/etc/ssl/certs/ca-certificates.crt")
}