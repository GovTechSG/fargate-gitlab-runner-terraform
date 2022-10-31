locals {
  manager_container_name           = format("cd-ecs-%s-%s-%s-manager", var.project_code, var.environment, var.service_name)
  cloudwatch_log_group_name        = format("cwl-%s-%s-%s", var.project_code, var.environment, var.service_name)
  cloudwatch_log_group_name_runner = format("cwl-%s-%s-%s-worker", var.project_code, var.environment, var.service_name)
  worker_task_name                 = format("task-%s-%s-%s-worker", var.project_code, var.environment, var.service_name)
  worker_exec_role_name            = format("iam-role-%s-%s-%s-worker-execution", var.project_code, var.environment, var.service_name)
}
