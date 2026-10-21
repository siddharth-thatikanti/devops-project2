output "alb_dns_name" { value = aws_lb.project2.dns_name }
output "target_group_arn" { value = aws_lb_target_group.project2.arn }
