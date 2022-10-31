locals {
  // Read environment specific's settings from env_inputs.hcl
  vars = read_terragrunt_config(find_in_parent_folders("env_inputs.hcl"))
}

// Persistent storage for terraform states
remote_state {
  backend = "s3"
  config = {
    bucket                 = local.vars.inputs.s3_state_bucket
    region                 = local.vars.inputs.aws_region
    dynamodb_table         = local.vars.inputs.s3_state_bucket
    encrypt                = true
    sts_endpoint           = "https://sts.${local.vars.inputs.aws_region}.amazonaws.com"
    skip_bucket_versioning = false
    key                    = "${path_relative_to_include()}"

    s3_bucket_tags = local.vars.inputs.tags_common

    dynamodb_table_tags = local.vars.inputs.tags_common
  }
}

// Hooks for terraform commands
terraform {
  after_hook "copy_common_tf" {
    commands = ["init-from-module"]
    execute = [
      "cp",
      "${find_in_parent_folders("common.tf")}",
      "."
    ]
  }

  after_hook "rm_common_tf" {
    commands = get_terraform_commands_that_need_vars()

    execute = [
      "rm",
      "${get_terragrunt_dir()}/common.tf"
    ]
    run_on_error = true
  }

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
