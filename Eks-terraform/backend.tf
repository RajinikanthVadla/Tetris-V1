terraform {
  backend "s3" {
    bucket = "rajinikanths3" # Replace with your actual S3 bucket name
    key    = "Eks/terraform.tfstate"
    region = "ap-south-1"
  }
}
