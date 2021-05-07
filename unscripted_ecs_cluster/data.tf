data "aws_vpc" "selected_vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.environment}VPC"]
  }
}

data "aws_subnet_ids" "selected_subnets" {

  vpc_id = data.aws_vpc.selected_vpc.id
  filter {
    name   = "tag:Environment"
    values = ["${var.environment}"]
  }
    filter {
    name   = "tag:Type"
    values = ["Public"]
  }
}

data "aws_security_group" "selected_security_group" {
  vpc_id = data.aws_vpc.selected_vpc.id
  filter {
    name   = "tag:Environment"
    values = ["${var.environment}"]
  }
}

data "aws_instance" "selected_ec2_instance" {
  depends_on = ["aws_autoscaling_group.ecs-autoscaling-group"]
  filter {
    name   = "tag:Environment"
    values = ["${var.environment}"]
  }
}