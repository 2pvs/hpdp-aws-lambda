terraform {
    required_version = ">= 0.14.6"
    backend "local" {
      path = "../../terraform/terraform.tfstate"
    }
}

provider "aws" {
  region     = var.aws_default_region
  #access_key = var.access_key
  #secret_key = var.secret_key
  profile    = var.aws_cli_profile
}

resource "aws_s3_bucket" "hpdp_lambda_data" {
  bucket = var.s3_bucket
  acl    = "private"
}

