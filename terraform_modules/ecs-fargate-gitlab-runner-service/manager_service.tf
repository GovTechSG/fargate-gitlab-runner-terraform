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

  vpc_id                         = var.vpc_id
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
      awslogs-region        = "ap-southeast-1"
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
      "name" : "RUNNER_NAME_PREFIX",
      "value" : var.gitlab_runner_name_prefix
    },
    {
      "name" : "RUNNER_TAG_LIST",
      "value" : var.gitlab_runner_tag_list
    },
    {
      "name" : "WORKER_CLUSTER",
      "value" : var.worker_ecs_cluster_arn
    },
    {
      "name" : "WORKER_REGION",
      "value" : var.aws_region
    },
    {
      "name" : "WORKER_SUBNET",
      "value" : var.worker_subnet_id
    },
    {
      "name" : "WORKER_SECURITY_GROUP",
      "value" : var.worker_security_group_id
    },
    {
      "name" : "WORKER_TASK_DEFINITION",
      "value" : module.worker_task_definition.arn
    }
  ]
  secrets = [
    {
      "name" : "GITLAB_REGISTRATION_TOKEN",
      "valueFrom" : var.gitlab_token_secret_arn
    }
  ]
}
