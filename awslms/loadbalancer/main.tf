################# loadbalancer/ main.tf #################

resource "aws_lb" "pranesh-lb" {
  name = "pranesh-loadbalancer"
  subnets = var.public_subnets
  security_groups = [var.public_sg]
  idle_timeout = 400
}


resource "aws_alb_target_group" "pranesh-tg" {
    name = "pranesh-lb-tg-$(substr(uuid , 0 ,3))"
    port = var.tg_port #80
    protocol = var.tg_protocol #http
    vpc_id = var.vpc_id
    lifecycle {
      ignore_changes = [name]
      create_before_destory = true
    }
    health_check {
      healthy_threshold = var.lb_healthy_threshold #2
      unhealthy_threshold = var.lb_unhealthy_threshold #2
      timeout = var.lb_timeout #3
      interval = var.lb_interval #30

    }

  
}

resource "aws_alb_listener" "alb-listener" {
    load_balancer_arn = aws_lb.pranesh-lb.arn
    port = var.listener_port #80
    protocol = var.listener_protocol #http
    default_action {
      type = "forward"
      target_group_arn = aws_alb_target_group.pranesh-tg.arn
    }
  
}