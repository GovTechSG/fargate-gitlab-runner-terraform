locals {
  // Read environment specific's settings from env_inputs.hcl
  vars = read_terragrunt_config(find_in_parent_folders("env_inputs.hcl"))

  default_tags = {
    Terraform        = "true"
    Terraform-Dir    = "${get_path_from_repo_root()}"
    Project-Name     = "${local.vars.inputs.project_name}"
    Environment      = "${local.vars.inputs.env}"
    Last-Modified-By = "${get_aws_caller_identity_arn()}"
  }
}

generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  backend "s3" {
  }

  required_version = ">= 0.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.6"
    }
  }
}
EOF
}

generate "provider_aws" {
  path      = "provider_aws.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region = "${local.vars.inputs.aws_region}"
  endpoints {
    sts = "https://sts.${local.vars.inputs.aws_region}.amazonaws.com"
  }

  default_tags {
    tags = ${jsonencode(local.default_tags)}
  }
}
EOF
}

// Persistent storage for terraform states
remote_state {
  backend = "s3"
  config  = {
    bucket                 = local.vars.inputs.s3_state_bucket
    region                 = local.vars.inputs.aws_region
    dynamodb_table         = local.vars.inputs.s3_state_bucket
    encrypt                = true
    sts_endpoint           = "https://sts.${local.vars.inputs.aws_region}.amazonaws.com"
    skip_bucket_versioning = false
    key                    = "${path_relative_to_include()}"

    s3_bucket_tags = merge(local.default_tags, { Created-By = "terragrunt" })

    dynamodb_table_tags = merge(local.default_tags, { Created-By = "terragrunt" })
  }
}

// Hooks for terraform commands
terraform {
  extra_arguments "force_regional_ep" {
    commands = concat(get_terraform_commands_that_need_vars(), ["import", "state", "init", "force-unlock", "output"])

    env_vars = {
      //     Without this env, sts:GetCallerIdentity action
      //     will face Credential should be scoped to a valid region, not 'us-east-1'
      //     error.
      //     Issue: https://github.com/hashicorp/terraform-provider-aws/issues/14435
      AWS_STS_REGIONAL_ENDPOINTS = "regional"
    }
  }
}
