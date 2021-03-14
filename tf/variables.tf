variable "aws_default_region" { default = "eu-central-1" }
variable "aws_cli_profile"    { default = "myaws" }
variable "access_key"         { default = "" }
variable "secret_key"         { default = "" }
variable "s3_bucket"          { default = "hpdp-lambda-data"} 
variable "destination_prefix" { default = "results/" }
variable "kicker_file_name"   { default = "job.start" }
