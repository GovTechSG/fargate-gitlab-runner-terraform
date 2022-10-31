variable "aws_region" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "project_code" {
  type = string
}

variable "service_name" {
  type = string
}

variable "manager_ecs_cluster_arn" {
  type = string
}

variable "manager_instance_count" {
  type    = number
  default = 1
}

variable "manager_security_group_ids" {
  type = list(string)
}

variable "manager_subnet_ids" {
  type = list(string)
}

variable "tags_common" {
  type    = map(string)
  default = {}
}

variable "gitlab_token_secret_arn" {
  type = string
}

variable "secrets_kms_key" {
  description = "KMS Key Id to decrypt the gitlab_token secret. Use default secretsmanager key if empty. Overwrite if needed"
  default     = ""
}

variable "manager_docker_image" {
}

variable "iam_permissions_boundary" {
  type    = string
  default = null
}

variable "gitlab_url" {
  type = string
}

variable "gitlab_runner_name_prefix" {
  type        = string
  description = "Prefix for the runner name as shown in Gitlab, can contain only alphanumeric characters, -, _ or . symbols."
}

variable "gitlab_runner_tag_list" {
  type        = string
  description = "Comma-separated list of tags to associate this Fargate runner with"
  default     = ""
}

variable "worker_ecs_cluster_arn" {
  type = string
}

variable "worker_subnet_id" {
  type = string
}

variable "worker_security_group_id" {
  type = string
}

variable "worker_docker_image" {
  type = string
}

variable "worker_cpu" {
  type        = number
  description = "The number of cpu units reserved for the container"
  default     = 256
}

variable "worker_memory" {
  type        = number
  description = "The hard limit (in MiB) of memory to present to the container"
  default     = 512
}

variable "worker_task_role_arn" {
  type        = string
  description = "The role that the worker task should take"
  default     = ""
}
