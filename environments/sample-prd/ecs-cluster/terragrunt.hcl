include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "tfr:///terraform-aws-modules/ecs/aws?version=4.1.1"
}

locals {
  // Read environment specific's settings from env_inputs.hcl
  vars = read_terragrunt_config(find_in_parent_folders("env_inputs.hcl"))
}

inputs = merge(local.vars.inputs,
  {
    cluster_name = "${local.vars.inputs.project_name}-${local.vars.inputs.env}-fargate-gitlab-runner"

    fargate_capacity_providers = {
      FARGATE = {
        default_capacity_provider_strategy = {
          weight = 50
        }
      }
      FARGATE_SPOT = {
        default_capacity_provider_strategy = {
          weight = 50
        }
      }
    }

    tags = local.vars.inputs.tags_common
  }
)
