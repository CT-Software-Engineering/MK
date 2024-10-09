terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }

  backend "gcs" {
    bucket = "militaryknowledge" # Replace with your GCS bucket name
    prefix = "neo4j/state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "kubernetes" {
  host  = "https://${local.kubernetes_internal_ip}:6443"
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
          image = "neo4j:latest"
          name  = "neo4j"

          env {
            name  = "NEO4J_AUTH"
            value = "neo4j/${var.neo4j_password}" # Set your Neo4j password
          }

          port {
            container_port = 7474
            name           = "http"
          }
          port {
            container_port = 7687
            name           = "bolt"
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
  }
}
