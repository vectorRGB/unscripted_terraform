module "vpc" {
  source = "github.com/bic-harness/terraform-aws-vpc"

  name = "${var.environment}VPC"

  cidr = "10.0.0.0/16"

  azs             = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_ipv6 = true

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_s3_endpoint       = false
  enable_dynamodb_endpoint = false

  public_subnet_tags = {
    Environment = "${var.environment}"
    Type        = "Public"
  }

  tags = {
    Environment = "${var.environment}"
  }

  vpc_tags = {
    Name = "${var.environment}VPC"
  }
}

resource "aws_default_security_group" "main_sg" {
  vpc_id      = module.vpc.vpc_id

  ingress {
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = "${var.environment}"
    Name        = "${var.environment}SG"
  }
}

