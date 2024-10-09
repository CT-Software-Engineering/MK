output "postgresql_service_ip" {
  description = "The IP address of the PostgreSQL service"
  value       = kubernetes_service.postgresql.status[0].load_balancer[0].ingress[0].ip
}