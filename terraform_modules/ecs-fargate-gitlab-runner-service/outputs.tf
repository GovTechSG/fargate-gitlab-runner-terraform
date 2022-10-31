output "manager_service_name" {
  value = module.manager_service.service_name
}

output "worker_task_definition_arn" {
  value = module.worker_task_definition.arn
}
