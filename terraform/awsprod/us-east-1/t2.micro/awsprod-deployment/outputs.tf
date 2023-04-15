# --- root/outputs.tf ---

output "load_balancer_endpoint" {
  value = module.resources.lb_endpoint
}

output "database_endpoint" {
  value = module.resources.db_endpoint
}