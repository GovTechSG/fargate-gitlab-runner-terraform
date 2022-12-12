variable "aws_region" {
  type = string
}

variable "environment" {
  type = string
}

variable "project_code" {
  type = string
}

variable "service_name" {
  description = "Name of the service, actual ECS service will be <project_code>-<environment>-<service_name>"
  type        = string
}

variable "manager_ecs_cluster_arn" {
  description = "ARN of the ECS Cluster for managers"
  type        = string
}

variable "manager_instance_count" {
  description = "Number of ECS Fargate instances. Final number of GitLab runners is manager_instance_count * length(keys(managers_configs))"
  type        = number
  default     = 1
}

variable "manager_cpu" {
  description = "CPU of Manager ECS task"
  type        = number
  default     = 256
}

variable "manager_memory" {
  description = "Memory of Manager ECS task"
  type        = number
  default     = 512
}

variable "manager_security_group_ids" {
  description = "Security Group IDs for manager ECS Fargate task"
  type        = list(string)
}

variable "manager_subnet_ids" {
  description = "Subnet IDs for manager ECS Fargate task"
  type        = list(string)
}

variable "tags_common" {
  description = "Additional common tags not included in aws provider's default_tags"
  type        = map(string)
  default     = {}
}

variable "gitlab_token_secret_arn" {
  description = "ARN of the secret in either Secret Manager or Parameter Store which stores the GitLab token for runner registration"
  type        = string
}

variable "secrets_kms_key" {
  description = "KMS Key Id to decrypt the gitlab_token secret. Use default secretsmanager key if empty. Overwrite if needed"
  default     = ""
}

variable "manager_docker_image" {
  description = ""
  type        = string
}

variable "iam_permissions_boundary" {
  description = "Permissions Boundary to be added to any generated IAM Role"
  type        = string
  default     = null
}

variable "gitlab_url" {
  description = "Full URL to GitLab instance, e.g., https://gitlab.com/"
  type        = string
}

variable "gitlab_runner_concurrency" {
  description = "Number of jobs that can run concurrently. Refer to the guide at https://www.howtogeek.com/devops/how-to-manage-gitlab-runner-concurrency-for-parallel-ci-jobs/"
  type        = number
  default     = 10
}

variable "gitlab_runner_name_prefix" {
  description = "Prefix for the runner name as shown in Gitlab, can contain only alphanumeric characters, -, _ or . symbols."
  type        = string
}

variable "managers_configs" {
  description = "Map of managers' names and their worker configs. Final number of GitLab runners is manager_instance_count * length(keys(managers_configs))"
  type = map(object({
    tags : list(string)
    limit : number, # Note that this is limited by the number of available IPs in the worker subnet
    worker_docker_image : string
    worker_cpu : number
    worker_memory : number
    worker_ecs_cluster_arn : string
    worker_aws_region : string
    worker_subnet_id : string
    worker_security_group_id : string
    worker_ssh_user : string
    worker_task_role_arn : string
  }))
  # default value as a sample
  default = {
    r1 : {
      tags : ["env1", "tool1", "tool2"]
      limit : 10
      worker_docker_image : "image_1"
      worker_cpu : 256
      worker_memory : 512
      worker_ecs_cluster_arn : "ecs_cluster_arn_1"
      worker_aws_region : "region-1"
      worker_subnet_id : "subnet-123"
      "worker_security_group_id" : "sg-321"
      "worker_ssh_user" : "user_1"
      "worker_task_role_arn" : "task_role_arn_1"
    }
  }
}
