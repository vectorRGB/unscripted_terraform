output "region" {
    value = var.region
}

output "clusterName" {
    value = aws_ecs_cluster.ecs-cluster.name
}
output "vpc" {
    value = data.aws_vpc.selected_vpc.id
}

output "subnets" {
    value = data.aws_subnet_ids.selected_subnets.ids
}

output "security_group" {
    value = data.aws_security_group.selected_security_group.id
}

output "alb_arn" {
    value = aws_lb.main_lb.arn
}

output "tg_name" {
    value = aws_lb_target_group.main_tg.name
}

output "tg_arn" {
    value = aws_lb_target_group.main_tg.arn
}

output "listener_name" {
    value = aws_lb_listener.main_listener.id
}

output "listener_arn" {
    value = aws_lb_listener.main_listener.arn
}

#output "listener_arn_rule" {
#    value = aws_lb_listener_rule.main_listener_rule.arn
#}