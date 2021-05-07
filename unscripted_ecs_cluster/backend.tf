terraform {
   backend "s3" {
   bucket = "bic-harness"
   key = "terraform-unscripted-ecs-cluster.tfstate"
   region = "eu-west-2"
  }
}