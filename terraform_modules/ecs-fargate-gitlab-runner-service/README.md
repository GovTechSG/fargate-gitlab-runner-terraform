<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_manager_container_definition"></a> [manager\_container\_definition](#module\_manager\_container\_definition) | cloudposse/ecs-container-definition/aws | 0.58.1 |
| <a name="module_manager_service"></a> [manager\_service](#module\_manager\_service) | cloudposse/ecs-alb-service-task/aws | 0.66.2 |
| <a name="module_worker_task_definition"></a> [worker\_task\_definition](#module\_worker\_task\_definition) | mongodb/ecs-task-definition/aws | 2.1.5 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.worker_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.manager_service_get_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.manager_service_run_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ecs_task_execution_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy.ecs_task_execution_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_kms_alias.secretsmanager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_alias) | data source |
| [aws_kms_key.secrets_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key) | data source |
| [aws_subnet.manager_subnet_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | n/a | yes |
| <a name="input_gitlab_runner_concurrency"></a> [gitlab\_runner\_concurrency](#input\_gitlab\_runner\_concurrency) | Number of jobs that can run concurrently. Refer to the guide at https://www.howtogeek.com/devops/how-to-manage-gitlab-runner-concurrency-for-parallel-ci-jobs/ | `number` | `10` | no |
| <a name="input_gitlab_runner_name_prefix"></a> [gitlab\_runner\_name\_prefix](#input\_gitlab\_runner\_name\_prefix) | Prefix for the runner name as shown in Gitlab, can contain only alphanumeric characters, -, \_ or . symbols. | `string` | n/a | yes |
| <a name="input_gitlab_token_secret_arn"></a> [gitlab\_token\_secret\_arn](#input\_gitlab\_token\_secret\_arn) | ARN of the secret in either Secret Manager or Parameter Store which stores the GitLab token for runner registration | `string` | n/a | yes |
| <a name="input_gitlab_url"></a> [gitlab\_url](#input\_gitlab\_url) | Full URL to GitLab instance, e.g., https://gitlab.com/ | `string` | n/a | yes |
| <a name="input_iam_permissions_boundary"></a> [iam\_permissions\_boundary](#input\_iam\_permissions\_boundary) | Permissions Boundary to be added to any generated IAM Role | `string` | `null` | no |
| <a name="input_manager_docker_image"></a> [manager\_docker\_image](#input\_manager\_docker\_image) | n/a | `string` | n/a | yes |
| <a name="input_manager_ecs_cluster_arn"></a> [manager\_ecs\_cluster\_arn](#input\_manager\_ecs\_cluster\_arn) | ARN of the ECS Cluster for managers | `string` | n/a | yes |
| <a name="input_manager_instance_count"></a> [manager\_instance\_count](#input\_manager\_instance\_count) | Number of ECS Fargate instances. Final number of GitLab runners is manager\_instance\_count * length(keys(managers\_configs)) | `number` | `1` | no |
| <a name="input_manager_security_group_ids"></a> [manager\_security\_group\_ids](#input\_manager\_security\_group\_ids) | Security Group IDs for manager ECS Fargate task | `list(string)` | n/a | yes |
| <a name="input_manager_subnet_ids"></a> [manager\_subnet\_ids](#input\_manager\_subnet\_ids) | Subnet IDs for manager ECS Fargate task | `list(string)` | n/a | yes |
| <a name="input_managers_configs"></a> [managers\_configs](#input\_managers\_configs) | Map of managers' names and their worker configs. Final number of GitLab runners is manager\_instance\_count * length(keys(managers\_configs)) | <pre>map(object({<br>    tags : list(string)<br>    limit : number, # Note that this is limited by the number of available IPs in the worker subnet<br>    worker_docker_image : string<br>    worker_cpu : number<br>    worker_memory : number<br>    worker_ecs_cluster_arn : string<br>    worker_aws_region : string<br>    worker_subnet_id : string<br>    worker_security_group_id : string<br>    worker_ssh_user : string<br>    worker_task_role_arn : string<br>  }))</pre> | <pre>{<br>  "r1": {<br>    "limit": 10,<br>    "tags": [<br>      "env1",<br>      "tool1",<br>      "tool2"<br>    ],<br>    "worker_aws_region": "region-1",<br>    "worker_cpu": 256,<br>    "worker_docker_image": "image_1",<br>    "worker_ecs_cluster_arn": "ecs_cluster_arn_1",<br>    "worker_memory": 512,<br>    "worker_security_group_id": "sg-321",<br>    "worker_ssh_user": "user_1",<br>    "worker_subnet_id": "subnet-123",<br>    "worker_task_role_arn": "task_role_arn_1"<br>  }<br>}</pre> | no |
| <a name="input_project_code"></a> [project\_code](#input\_project\_code) | n/a | `string` | n/a | yes |
| <a name="input_secrets_kms_key"></a> [secrets\_kms\_key](#input\_secrets\_kms\_key) | KMS Key Id to decrypt the gitlab\_token secret. Use default secretsmanager key if empty. Overwrite if needed | `string` | `""` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Name of the service, actual ECS service will be <project\_code>-<environment>-<service\_name> | `string` | n/a | yes |
| <a name="input_tags_common"></a> [tags\_common](#input\_tags\_common) | Additional common tags not included in aws provider's default\_tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_manager_service_name"></a> [manager\_service\_name](#output\_manager\_service\_name) | Name of the ECS Service for managers |
| <a name="output_worker_task_definition_arns"></a> [worker\_task\_definition\_arns](#output\_worker\_task\_definition\_arns) | ARNs of workers' task definitions |
<!-- END_TF_DOCS -->