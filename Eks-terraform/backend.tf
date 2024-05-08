terraform {
  backend "s3" {
    bucket = "rajinikanths32024" # Replace with your actual S3 bucket name
    key    = "Eks/terraform.tfstate"
    region = "ap-south-1"
  }
}
