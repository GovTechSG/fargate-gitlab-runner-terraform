data "aws_kms_alias" "secretsmanager" {
  name = "alias/aws/secretsmanager"
}

data "aws_kms_key" "secrets_kms_key" {
  key_id = coalesce(var.secrets_kms_key, data.aws_kms_alias.secretsmanager.target_key_id)
}

resource "aws_iam_role_policy" "manager_service_get_secret" {
  name = format("iam-policy-%s-%s-%s-get-secret", var.project_code, var.environment, var.service_name)
  role = module.manager_service.task_exec_role_name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters",
        "secretsmanager:GetSecretValue",
        "kms:Decrypt"
      ],
      "Resource": [
        "${var.gitlab_token_secret_arn}",
        "${data.aws_kms_key.secrets_kms_key.arn}"
      ]
    }
  ]
}
EOF
}

locals {
  task_definition_arns = toset(concat(
    [for key, value in var.managers_configs : "${replace(value.worker_ecs_cluster_arn, ":cluster/", ":task/")}/*"],
    [for key, value in var.managers_configs : replace(module.worker_task_definition[key].arn, "/[[:digit:]]+$/", "*")]
  ))
}

resource "aws_iam_role_policy" "manager_service_run_task" {
  name = "iam-policy-${var.service_name}-run-task"
  role = module.manager_service.task_role_name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowManageTasks",
      "Effect": "Allow",
      "Action": [
        "ecs:RunTask",
        "ecs:StartTask",
        "ecs:StopTask",
        "ecs:DescribeTasks"
      ],
      "Resource": ${jsonencode(local.task_definition_arns)}
    },
    {
      "Sid": "AllowListTasks",
      "Effect": "Allow",
      "Action": [
        "ecs:ListTaskDefinitions",
        "ecs:DescribeTaskDefinition"
      ],
      "Resource": "*"
    },
    {
      "Sid": "AllowPassWorkerECSExecRole",
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "${aws_iam_role.worker_execution_role.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role" "worker_execution_role" {
  name = local.worker_exec_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })
  permissions_boundary = var.iam_permissions_boundary
  tags                 = var.tags_common
}

data "aws_iam_policy" "ecs_task_execution_role_policy" {
  name = "AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.worker_execution_role.id
  policy_arn = data.aws_iam_policy.ecs_task_execution_role_policy.arn
}