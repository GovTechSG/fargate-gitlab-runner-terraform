# fargate-gitlab-runner-terraform

Terraform module for deploying ECS service for Fargate GitLab runner, with sample environment setups for `dev` and `prd` using Terragrunt.

This repo is part of a set of repos for the complete setup of ECS Service for managers and workers:
* [fargate-gitlab-runner](../../../fargate-gitlab-runner): Docker image for the ECS task for all runner managers
* [fargate-gitlab-runner-worker](../../../fargate-gitlab-runner-worker): Sample docker images for the worker ECS tasks
* [fargate-gitlab-runner-terraform](../../../fargate-gitlab-terraform): Terraform code to set up complete ECS Service for managers and workers

## Architecture
![ECS Fargate GitLab runner Architecture](assets/ECS%20Fargate%20GitLab%20runner%20Architecture.png)

## Folder structure
```
|_ environments
   |_ sample-dev                               # Sample dev environment
      |_ ...
      |_ ecs-fargate-gitlab-runner-service     # Specification of the ECS service module for this environment
         |_ terragrunt.hcl
      |_ env_inputs.hcl                        # Environment-specific parameters
   |
   |_ sample-prd                               # Sample prd environment
      |_ ...
      |_ env_inputs.hcl
   |
   |_ terragrunt.hcl                           # Common Terragrunt config for all environments
|
|_ terraform_modules
   |_ ecs-fargate-gitlab-runner-service        # Module for ECS service for Fargate GitLab runner
```

This folder structure follows [Terragrunt's](https://terragrunt.gruntwork.io/docs/getting-started/quick-start/#promote-immutable-versioned-terraform-modules-across-environments)'s recommendation to keep Terraform configurations DRY:
* Terraform modules are kept in `terraform_modules`
* Common Terragrunt settings for all environments are kept at `environments/terragrunt.hcl`
* Each environment can provide its own parameters in `environments/<env>/env_inputs.hcl`
* Live modules for deployment are kept in each environment's folder with a `terragrunt.hcl` to provide link to the module in `terraform_modules` and provide variables' values in `inputs` block


## Usage
### Pre-requisites:
Following resources are required to be set up either manually or via another set of Terraform code (recommended):
* Secret for GitLab Token: Obtain token for runners from GitLab, create a new secret in either AWS Secret Manager or System Manager Parameter Store. Take note of the KMS key used.
* VPC, subnets and security groups required for both managers and workers. Take note that SSH communication via port 22 need to be allowed between managers' and workers' network ACLs and security groups.
* Workers' ECS Task roles with appropriate policies for the worker tasks to access AWS services.

### Setup

* Copy from `environments/sample-dev` to a new env `environments/<env>`
* Update your environment settings at `environments/<env>/env_inputs.hcl`.
* If there's no existing ECS Cluster for either managers or workers, create new one(s) following the samples at `environments/<env>/ecs-cluster-for-managers` or `environments/<env>/ecs-cluster-for-workers`.
* Update variable values in `environments/<env>/ecs-fargate-gitlab-runner-service/terragrunt.hcl` matching your environment. Refer to [environments/sample-dev/ecs-fargate-gitlab-runner-service/terragrunt.hcl](environments/sample-dev/ecs-fargate-gitlab-runner-service/terragrunt.hcl) for sample values. Snippet:
```hcl
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
```

## Deployment with `terragrunt`
```shell
cd environments/<env>/ecs-fargate-gitlab-runner-service
terragrunt apply
```

If you prefer to use Terraform instead of Terragrunt for a quick test,
- Create `terraform.tfvars` file in folder terraform_modules/ecs-fargate-gitlab-runner-service with all variable values found in `environments/<env>/ecs-fargate-gitlab-runner-service/terragrunt.hcl`
- Copy content of `versions.tf` and `provider.tf` from `environments/terragrunt.hcl` into their respective files in `terraform_modules/ecs-fargate-gitlab-runner-service`.
- Finally, run `terraform apply`.


## Test Gitlab job
Use this code for a simple test of the created GitLab runner(s):
```yaml
test:
  tags:
    # these should match all the tags set in the manager configs or a subset (note that a subset may mean other non-Fargate runners can pick up the job, depending on your setup)
    - dev
    - tool1
  script:
    - echo "It works!"
    - for i in $(seq 1 30); do echo "."; sleep 1; done
```


## More info on `ecs-fargate-gitlab-runner-service` Terraform module
Refer to [terraform_modules/ecs-fargate-gitlab-runner-service/README.md](terraform_modules/ecs-fargate-gitlab-runner-service/README.md) for detailed documentation of the module.

**Important parameters:**

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gitlab_runner_concurrency"></a> [gitlab\_runner\_concurrency](#input\_gitlab\_runner\_concurrency) | Number of jobs that can run concurrently. Refer to the guide at https://www.howtogeek.com/devops/how-to-manage-gitlab-runner-concurrency-for-parallel-ci-jobs/ | `number` | `10` | no |
| <a name="input_gitlab_token_secret_arn"></a> [gitlab\_token\_secret\_arn](#input\_gitlab\_token\_secret\_arn) | ARN of the secret in either Secret Manager or Parameter Store which stores the GitLab token for runner registration | `string` | n/a | yes |
| <a name="input_manager_docker_image"></a> [manager\_docker\_image](#input\_manager\_docker\_image) | n/a | `string` | n/a | yes |
| <a name="input_manager_ecs_cluster_arn"></a> [manager\_ecs\_cluster\_arn](#input\_manager\_ecs\_cluster\_arn) | ARN of the ECS Cluster for managers | `string` | n/a | yes |
| <a name="input_manager_instance_count"></a> [manager\_instance\_count](#input\_manager\_instance\_count) | Number of ECS Fargate instances. Final number of GitLab runners is manager\_instance\_count * length(keys(managers\_configs)) | `number` | `1` | no |
| <a name="input_managers_configs"></a> [managers\_configs](#input\_managers\_configs) | Map of managers' names and their worker configs. Final number of GitLab runners is manager\_instance\_count * length(keys(managers\_configs)) | <pre>map(object({<br>    tags : list(string)<br>    limit : number, # Note that this is limited by the number of available IPs in the worker subnet<br>    worker_docker_image : string<br>    worker_cpu : number<br>    worker_memory : number<br>    worker_ecs_cluster_arn : string<br>    worker_aws_region : string<br>    worker_subnet_id : string<br>    worker_security_group_id : string<br>    worker_ssh_user : string<br>    worker_task_role_arn : string<br>  }))</pre> | <pre>{<br>  "r1": {<br>    "limit": 10,<br>    "tags": [<br>      "env1",<br>      "tool1",<br>      "tool2"<br>    ],<br>    "worker_aws_region": "region-1",<br>    "worker_cpu": 256,<br>    "worker_docker_image": "image_1",<br>    "worker_ecs_cluster_arn": "ecs_cluster_arn_1",<br>    "worker_memory": 512,<br>    "worker_security_group_id": "sg-321",<br>    "worker_ssh_user": "user_1",<br>    "worker_subnet_id": "subnet-123",<br>    "worker_task_role_arn": "task_role_arn_1"<br>  }<br>}</pre> | no |


### Troubleshooting
Followings are some issues that can occur:

**Unable to start Fargate Task due to No Container Instances were found in your cluster error**
* Check your ECS Cluster for workers and make sureDefault capacity provider strategy is set to FARGATE

**Manager unable to connect to ECS to start a task**
* If the managers are hosted in private subnets, create VPC endpoints for ECS and ECR and make sure the managers can access them.

**Manager unable to connect to worker ECS task via ssh**
* Make sure your worker container image has openssh installed and `SSH_PUBLIC_KEY` is added to the right user's `~/.ssh/authorized_keys`.
* Check that the subnets and security groups of both managers and workers allow traffic on port 22. Use the VPC Reachability Analyzer to confirm.
* If the error is `signature algorithm ssh-rsa not in PubkeyAcceptedAlgorithms`, enable `ssh-rsa` by adding this to worker container image: `RUN echo "PubkeyAcceptedKeyTypes +ssh-rsa" >> /etc/ssh/sshd_config`.

**Worker ECS task has no credentials to access AWS**
* Share the variable `AWS_CONTAINER_CREDENTIALS_RELATIVE_URI` with the SSH session by adding this to sshd run:
`-o "SetEnv=AWS_CONTAINER_CREDENTIALS_RELATIVE_URI=\"$AWS_CONTAINER_CREDENTIALS_RELATIVE_URI\""`

### Known Limitation:
* The Fargate driver doesn't support ECS Exec yet. For more info: https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/issues/49
