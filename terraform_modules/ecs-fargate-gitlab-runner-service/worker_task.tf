module "worker_task_definition" {
  # https://registry.terraform.io/modules/mongodb/ecs-task-definition/aws/latest
  source  = "mongodb/ecs-task-definition/aws"
  version = "2.1.5"

  # Hardcoded name required by the Fargate executor driver
  # https://docs.gitlab.com/runner/configuration/runner_autoscale_aws_fargate/#step-6-create-an-ecs-task-definition
  name   = "ci-coordinator"
  family = local.worker_task_name
  image  = var.worker_docker_image
  cpu    = var.worker_cpu
  memory = var.worker_memory

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  task_role_arn            = var.worker_task_role_arn
  execution_role_arn       = aws_iam_role.worker_execution_role.arn

  portMappings = [
    {
      containerPort = 22 # expose SSH port for manager service to connect
    }
  ]

  logConfiguration = {
    logDriver = "awslogs"
    options = {
      awslogs-region        = "ap-southeast-1"
      awslogs-stream-prefix = local.worker_task_name
      awslogs-group         = local.cloudwatch_log_group_name
    }
  }

  tags = var.tags_common
}
