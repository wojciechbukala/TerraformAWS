terraform {
  backend "s3" {
    bucket = "tf-state-bukala"
    key = "global/s3/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}
