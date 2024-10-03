terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }

  backend "gcs" {
    bucket = "militaryknowledge"
    prefix = "postgresql/state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
provider "kubernetes" {
  host  = "https://${local.kubernetes_internal_ip}:6443"  # Use dynamically fetched internal IP
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

resource "kubernetes_namespace" "postgresql" {
  metadata {
    name = "postgresql"
  }
}

resource "kubernetes_secret" "postgresql_secrets" {
  metadata {
    name      = "postgresql-secrets"
    namespace = kubernetes_namespace.postgresql.metadata[0].name
  }

  data = {
    POSTGRES_USER     = var.postgresql_username
    POSTGRES_PASSWORD = var.postgresql_password
  }
}

resource "kubernetes_deployment" "postgresql" {
  metadata {
    name      = "postgresql"
    namespace = kubernetes_namespace.postgresql.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "postgresql"
      }
    }

    template {
      metadata {
        labels = {
          app = "postgresql"
        }
      }

      spec {
        container {
          image = "postgres:13"
          name  = "postgresql"

          port {
            container_port = 5432
            name           = "postgresql"
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.postgresql_secrets.metadata[0].name
            }
          }

          volume_mount {
            name       = "postgresql-data"
            mount_path = "/var/lib/postgresql/data"
          }
        }

        volume {
          name = "postgresql-data"
          empty_dir {}
        }
      }
    }
  }
}

resource "kubernetes_service" "postgresql" {
  metadata {
    name      = "postgresql"
    namespace = kubernetes_namespace.postgresql.metadata[0].name
  }
  spec {
    selector = {
      app = kubernetes_deployment.postgresql.spec[0].template[0].metadata[0].labels.app
    }
    port {
      port        = 5432
      target_port = 5432
      name        = "postgresql"
    }
  }
}

resource "null_resource" "fetch_postgresql_cluster_ip" {
  provisioner "local-exec" {
    command = "./get_postgresql_cluster_ip.sh > postgresql_cluster_ip.txt"
  }

  triggers = {
    always_run = "${timestamp()}"
  }

  depends_on = [kubernetes_service.postgresql]
}

data "local_file" "postgresql_cluster_ip" {
  filename = "postgresql_cluster_ip.txt"

  depends_on = [null_resource.fetch_postgresql_cluster_ip]
}

locals {
  postgresql_cluster_ip = chomp(data.local_file.postgresql_cluster_ip.content)
}

output "postgresql_cluster_ip" {
  value = local.postgresql_cluster_ip
}