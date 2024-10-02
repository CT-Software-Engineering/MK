output "neo4j_service_name" {
  description = "The name of the Neo4j Kubernetes service"
  value       = kubernetes_service.neo4j.metadata[0].name
}

output "neo4j_connection_string" {
  description = "Connection string for Neo4j (use with kubectl port-forward)"
  value       = "bolt://localhost:7687"
}
