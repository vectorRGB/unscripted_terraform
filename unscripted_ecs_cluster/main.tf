locals {
 isStaging = var.environment == "Staging" ? true : false
 isProd    = var.environment == "Prod" ? true : false 
}

resource "aws_ecs_cluster" "ecs-cluster" {
    name  = "${var.environment}ECSCluster"
}

resource "aws_autoscaling_group" "ecs-autoscaling-group" {
  name                        = "${var.environment}ECS-ASG"
  max_size                    = "2"
  min_size                    = "1"
  desired_capacity            = "1"
  vpc_zone_identifier         = data.aws_subnet_ids.selected_subnets.ids
  launch_configuration        = aws_launch_configuration.ecs-launch-configuration.name
  health_check_type           = "ELB"

  tag {
    key                 = "Environment"
    value               = "${var.environment}"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "ecs-launch-configuration" {
  name                        = "${var.environment}ECS-LC"
  image_id                    = "ami-0e4249602c03f799a"
  instance_type               = "m5d.large"
  iam_instance_profile        = "ECSRoleForEC2"
  root_block_device {
    volume_type = "standard"
    volume_size = 30
    delete_on_termination = true
  }
  lifecycle {
    create_before_destroy = true
  }
  security_groups             = ["${data.aws_security_group.selected_security_group.id}"]
  associate_public_ip_address = "true"
  key_name                    = "bc-harness"
  user_data                   = "#!/bin/bash\necho ECS_CLUSTER='${aws_ecs_cluster.ecs-cluster.name}' > /etc/ecs/ecs.config"
}

resource "aws_lb" "main_lb" {
  load_balancer_type = "application"
  name               = "${var.environment}ALB"
  subnets            = data.aws_subnet_ids.selected_subnets.ids
}

resource "aws_lb_target_group" "main_tg" {
  name          = "${var.environment}ALB-tg"
  port          = 80
  protocol      = "HTTP"
  target_type   = "instance"
  vpc_id        = data.aws_vpc.selected_vpc.id
  stickiness {
      type = "lb_cookie"
      enabled = true
      cookie_duration = 1
  }
}

resource "aws_lb_listener" "main_listener" {
  load_balancer_arn = aws_lb.main_lb.arn

  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main_tg.arn
    }
}

resource "aws_lb_target_group_attachment" "main_attachment" {
  target_group_arn = aws_lb_target_group.main_tg.arn
  target_id        = data.aws_instance.selected_ec2_instance.id
  port             = 80
}

resource "aws_route53_record" "staging" {
  count   = local.isStaging ? 1 : 0
  zone_id = var.primary_zone_id
  name    = "staging.bicatana.net"
  type    = "A"

  alias {
    name                   = aws_lb.main_lb.dns_name
    zone_id                = aws_lb.main_lb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "prod" {
  count   = local.isProd ? 1 : 0
  zone_id = var.primary_zone_id
  name    = "unscripted.bicatana.net"
  type    = "A"

  alias {
    name                   = aws_lb.main_lb.dns_name
    zone_id                = aws_lb.main_lb.zone_id
    evaluate_target_health = true
  }
}
/*
resource "aws_instance" "sample_server" {
  ami                    = "ami-0a0cb6c7bcb2e4c51"
  instance_type          = "t2.micro"
  key_name               = "bc-harness"
  vpc_security_group_ids = ["sg-01c4818eac2729203"]
  
  tags = {
    Name        = "Sample Server"
  }
}
*/