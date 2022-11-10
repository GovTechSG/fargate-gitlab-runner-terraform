output "manager_service_name" {
  description = "Name of the ECS Service for managers"
  value       = module.manager_service.service_name
}

output "worker_task_definition_arns" {
  description = "ARNs of workers' task definitions"
  value       = { for key, value in module.worker_task_definition : key => value.arn }
}
