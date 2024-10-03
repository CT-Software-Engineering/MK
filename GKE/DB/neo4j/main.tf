terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  host  = "https://${local.kubernetes_internal_ip}:6443" # Use dynamically fetched internal IP
  token = var.kubernetes_token
}

resource "null_resource" "fetch_internal_ip" {
  provisioner "local-exec" {
    command = "./get_internal_ip.sh > internal_ip.txt"
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

data "local_file" "internal_ip" {
  filename = "internal_ip.txt"

  depends_on = [null_resource.fetch_internal_ip]
}

locals {
  kubernetes_internal_ip = chomp(data.local_file.internal_ip.content)
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

resource "null_resource" "fetch_cluster_ip" {
  provisioner "local-exec" {
    command = "./get_cluster_ip.sh > cluster_ip.txt"
  }

  triggers = {
    always_run = "${timestamp()}"
  }

  depends_on = [kubernetes_service.neo4j]
}

data "local_file" "cluster_ip" {
  filename = "cluster_ip.txt"

  depends_on = [null_resource.fetch_cluster_ip]
}

locals {
  neo4j_cluster_ip = chomp(data.local_file.cluster_ip.content)
}

output "neo4j_cluster_ip" {
  value = local.neo4j_cluster_ip
}
