terraform {
  backend "s3" {
    bucket         = var.bucket_name
    key            = "my-terraform-environment/main/terraform.tfstate"
    region         = var.aws_region
    #dynamodb_table = var.dynamodb_table
  }
}
