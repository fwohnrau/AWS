#Application loadbalancer

resource "aws_lb_target_group" "default" {
  name     = "default"
  port     = var.hostPort
  protocol = "HTTP"
  vpc_id   = var.vpc
}

resource "aws_lb_target_group" "Blue" {
  name     = "myEcommerTargetGroupBlue"
  port     = var.hostPort
  protocol = "HTTP"
  vpc_id   = var.vpc

  health_check {
    matcher = "200-400"
    protocol = "HTTP"
    healthy_threshold   = 10
    unhealthy_threshold = 4
    timeout             = 5
    path                = "/polls"
    interval            = 10
  }


}

resource "aws_lb_target_group" "Green" {
  name     = "myEcommerTargetGroupGreen"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc

  health_check {
    matcher = "200-301"
    protocol = "HTTP"
    healthy_threshold   = 10
    unhealthy_threshold = 4
    timeout             = 5
    path                = "/admin"
    interval            = 10
  }


}


resource "aws_lb" "ALB" {
  name               = "myEcommerceALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ALB.id]
  subnets            = [var.subnet_primary_1, var.subnet_primary_2]
  idle_timeout       = 30

  enable_deletion_protection = false

 # access_logs {
 #   bucket  = "ecomerce-alb-logs"
 #   prefix  = "test-lb"
 #   enabled = true
 # }

  tags = {
    Environment = var.environment
  }
}

resource "aws_lb_listener" "ALBListener" {
  load_balancer_arn = aws_lb.ALB.arn
    #port = "443"
    port = var.hostPort
    protocol = "HTTP"
    #ssl_policy = "ELBSecurityPolicy-2016-08"
    #certificate_arn = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }
}

resource "aws_lb_listener_rule" "ALBListenerRule" {

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Blue.arn
  }

  condition {
    path_pattern {
      values = ["/polls*","/admin*"]
    }
  }

  listener_arn = aws_lb_listener.ALBListener.arn
  priority     = 2

  #condition {
  #  host_header {
  #    values = ["example.com"]
  #  }
  #}
}





