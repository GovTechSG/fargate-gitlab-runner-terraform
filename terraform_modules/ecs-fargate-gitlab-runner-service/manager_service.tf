locals {
  manager_configs = {
    for key, value in var.managers_configs :
    key => merge(value, {
      "manager_name" : key
      "tag_list" : join(",", value.tags)
      "worker_task_definition_arn" : module.worker_task_definition[key].arn
    })
  }
}

data "aws_subnet" "manager_subnet_1" {
  id = var.manager_subnet_ids[0]
}

module "manager_service" {
  # https://registry.terraform.io/modules/cloudposse/ecs-alb-service-task/aws/latest
  source  = "cloudposse/ecs-alb-service-task/aws"
  version = "0.66.2"

  namespace = var.project_code
  stage     = var.environment
  name      = var.service_name

  container_definition_json = jsonencode([module.manager_container_definition.json_map_object])

  ecs_cluster_arn = var.manager_ecs_cluster_arn
  launch_type     = "FARGATE"

  vpc_id                         = data.aws_subnet.manager_subnet_1.vpc_id
  security_group_ids             = var.manager_security_group_ids
  subnet_ids                     = var.manager_subnet_ids
  ignore_changes_task_definition = false
  deployment_controller_type     = "ECS"
  desired_count                  = var.manager_instance_count
  task_memory                    = 512 # Use minimum memory and cpu settings
  task_cpu                       = 256
  permissions_boundary           = var.iam_permissions_boundary

  tags = var.tags_common
}

module "manager_container_definition" {
  # https://registry.terraform.io/modules/cloudposse/ecs-container-definition/aws/latest
  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.58.1"

  container_name  = local.manager_container_name
  container_image = var.manager_docker_image
  essential       = "true"

  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-create-group  = true
      awslogs-region        = var.aws_region
      awslogs-stream-prefix = var.service_name
      awslogs-group         = local.cloudwatch_log_group_name
    }
  }

  environment = [
    {
      "name" : "GITLAB_URL",
      "value" : var.gitlab_url
    },
    {
      "name" : "RUNNER_CONCURRENCY",
      "value" : var.gitlab_runner_concurrency
    },
    {
      "name" : "RUNNER_NAME_PREFIX",
      "value" : var.gitlab_runner_name_prefix
    },
    {
      "name" : "MANAGERS_CONFIGS",
      "value" : jsonencode(local.manager_configs)
    },
  ]
  secrets = [
    {
      "name" : "GITLAB_REGISTRATION_TOKEN",
      "valueFrom" : var.gitlab_token_secret_arn
    }
  ]
}
