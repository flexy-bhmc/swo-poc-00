terraform {
  backend "s3" {
    bucket = "627935236173-tf-state"
    key = "eu-west-1/terraform.tfstate"
    region = "eu-west-1"
  }
}