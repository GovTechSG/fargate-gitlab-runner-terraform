include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "${get_parent_terragrunt_dir()}/..//terraform_modules/ecs-fargate-gitlab-runner-service"
}

locals {
  // Read environment specific's settings from env_inputs.hcl
  vars = read_terragrunt_config(find_in_parent_folders("env_inputs.hcl"))
}

inputs = merge(local.vars.inputs,
  {
    project_code = local.vars.inputs.project_name
    environment  = local.vars.inputs.env
    service_name = "--SERVICE-NAME--"

    manager_instance_count     = 1
    manager_ecs_cluster_arn    = "arn:aws:ecs:${local.vars.inputs.aws_region}:${local.vars.inputs.aws_account_id}:cluster/<MANAGER_CLUSTER_NAME>"
    manager_docker_image       = "${local.vars.inputs.aws_account_id}.dkr.ecr.${local.vars.inputs.aws_region}.amazonaws.com/<MANAGER_DOCKER_IMAGE>"
    manager_subnet_ids         = ["<MANAGER_SUBNET_1>", "<MANAGER_SUBNET_2>", "<MANAGER_SUBNET_3>"]
    manager_security_group_ids = ["<MANAGER_SECURITY_GROUP_1>"]
    gitlab_token_secret_arn    = "arn:aws:secretsmanager:${local.vars.inputs.aws_region}:${local.vars.inputs.aws_region}:secret:PATH_TO_GITLAB_TOKEN"

    gitlab_url                = "<GITLAB_FULL_URL>"
    gitlab_runner_concurrency = 10
    gitlab_runner_name_prefix = "<RUNNER_NAME_PREFIX>"

    managers_configs = {
      dev_tool1 : {
        tags : ["dev", "tool1"]
        limit : 10 # Check the available IPs in worker subnet
        worker_docker_image : "${local.vars.inputs.aws_account_id}.dkr.ecr.${local.vars.inputs.aws_region}.amazonaws.com/<WORKER_DOCKER_IMAGE_1>"
        worker_cpu : 256
        worker_memory : 512
        worker_ecs_cluster_arn : "arn:aws:ecs:${local.vars.inputs.aws_region}:${local.vars.inputs.aws_account_id}:cluster/<ECS_CLUSTER_NAME>"
        worker_aws_region : local.vars.inputs.aws_region
        worker_subnet_id : "WORKER_SUBNET_1"
        worker_security_group_id : "WORKER_SECURITY_GROUP_1"
        worker_ssh_user : "user_1"
        worker_task_role_arn : "arn:aws:iam::${local.vars.inputs.aws_account_id}:role/<WORKER_IAM_ROLE_1>"
      }
      dev_tool2_tool3 : {
        tags : ["dev", "tool2", "tool3"]
        limit : 5 # Check the available IPs in worker subnet
        worker_docker_image : "${local.vars.inputs.aws_account_id}.dkr.ecr.${local.vars.inputs.aws_region}.amazonaws.com/<WORKER_DOCKER_IMAGE_2>"
        worker_cpu : 512
        worker_memory : 2048
        worker_ecs_cluster_arn : "arn:aws:ecs:${local.vars.inputs.aws_region}:${local.vars.inputs.aws_account_id}:cluster/<ECS_CLUSTER_NAME>"
        worker_aws_region : local.vars.inputs.aws_region
        worker_subnet_id : "WORKER_SUBNET_2"
        worker_security_group_id : "WORKER_SECURITY_GROUP_2"
        worker_ssh_user : "user_2"
        worker_task_role_arn : "arn:aws:iam::${local.vars.inputs.aws_account_id}:role/<WORKER_IAM_ROLE_2>"
      }
    }

    iam_permissions_boundary = "" # modify as required
  }
)

dependencies {
  paths = ["../ecs-cluster-for-managers", "../ecs-cluster-for-workers"]
}
