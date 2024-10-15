output "neo4j_service_ip" {
  description = "The IP address of the Neo4j service"
  value       = kubernetes_service.neo4j.status[0].load_balancer[0].ingress[0].ip
}