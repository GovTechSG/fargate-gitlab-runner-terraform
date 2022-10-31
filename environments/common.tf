terraform {
  backend "s3" {
  }

  required_version = ">= 0.13"
}

provider "aws" {
  region = "ap-southeast-1"
  endpoints {
    sts = "https://sts.ap-southeast-1.amazonaws.com"
  }
}
