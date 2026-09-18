terraform {
  backend "s3" {
    bucket  = "barista-cafe-tfstate-331094056355-us-east-1"
    key     = "barista-cafe/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
