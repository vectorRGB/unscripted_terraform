terraform {
   backend "s3" {
   bucket = "bic-harness"
   key = "terraform-unscripted-vpc.tfstate"
   region = "eu-west-2"
  }
}