# Outputs
output "neo4j_service_name" {
  value       = kubernetes_service.neo4j.metadata[0].name
  description = "The name of the Neo4j service."
}

output "neo4j_service_namespace" {
  value       = kubernetes_namespace.neo4j.metadata[0].name
  description = "The namespace where Neo4j is deployed."
}

output "neo4j_pvc_name" {
  value       = kubernetes_persistent_volume_claim.neo4j_pvc.metadata[0].name
  description = "The name of the Neo4j persistent volume claim."
}

output "neo4j_pv_name" {
  value       = kubernetes_persistent_volume.neo4j_pv.metadata[0].name
  description = "The name of the Neo4j persistent volume."
}

output "neo4j_service_ip" {
  value       = kubernetes_service.neo4j.status[0].load_balancer[0].ingress[0].ip
  description = "The external IP of the Neo4j service (if applicable)."
}

output "neo4j_port" {
  value       = 7474
  description = "The port used to connect to the Neo4j service."
}
