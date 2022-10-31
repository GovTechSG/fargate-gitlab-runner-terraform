inputs = {
  aws_region      = "ap-southeast-1"
  aws_account_id  = "987654321098"
  project_name    = "my-project"
  env             = "prd"
  s3_state_bucket = "__S3_STATE_BUCKET__"

  tags_common = {
    Terraform     = "true"
    Project-Name  = "my-project"
    Environment   = "prd"
    Terraform-Dir = get_path_from_repo_root()
  }
}
