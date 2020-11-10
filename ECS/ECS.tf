#Create logs group
resource "aws_cloudwatch_log_group" "ECSGroup" {
  name = var.logGroup
  retention_in_days = 1
}


#Create Security Groups
resource "aws_security_group" "Autoscalling"{
  name  = "Terraform-Autoscalling-EC2-SG"
  vpc_id = var.vpc

  ingress {
    protocol = "tcp"
    from_port = var.containerPort
    to_port = var.containerPort
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
        from_port       = 0
        to_port         = 65535
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

}

resource "aws_security_group" "ALB"{
  name  = "Terraform-myEcommerce-ALB-SG"
  vpc_id = var.vpc

  ingress {
    protocol = "tcp"
    from_port = var.hostPort
    to_port = var.hostPort
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
        from_port       = 0
        to_port         = 65535
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

}

resource "aws_security_group" "Container"{
  name  = "Terraform-Container-SG"
  vpc_id = var.vpc

  ingress {
    protocol = "tcp"
    from_port = var.hostPort
    to_port = var.hostPort
    security_groups = [aws_security_group.ALB.arn]
  }

}

#Create Role and Profiles

resource "aws_iam_role" "Terraform-ECS-EC2-Role" {
  name = "Terraform-ECS-EC2-Role"

   assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }

  ]
}
EOF

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_policy" "Terraform-Ecommerce-ECS-ECR" {
  name        = "Terraform-Ecommerce-ECS-ECR-policy"
  description = "Policy to maintain container Ecommerce docker image"
  policy      =  file("Ecommerce-ECR-Policy.json")
}

resource "aws_iam_policy" "Terraform-Ecommerce-ECS" {
  name        = "Terraform-Ecommerce-ECS-policy"
  description = "Policy to run ECS on EC2"
  policy      =  file("Ecommerce-ECS-Policy.json")
}

resource "aws_iam_role_policy_attachment" "Terraform-Ecommerce-ECS-ECR-policy" {
  role       = aws_iam_role.Terraform-ECS-EC2-Role.name
  policy_arn = aws_iam_policy.Terraform-Ecommerce-ECS-ECR.arn
}

resource "aws_iam_role_policy_attachment" "Terraform-Ecommerce-ECS-policy" {
  role       = aws_iam_role.Terraform-ECS-EC2-Role.name
  policy_arn = aws_iam_policy.Terraform-Ecommerce-ECS.arn
}

resource "aws_iam_instance_profile" "ECS-InstanceProfile"{
  name = "Terraform-ECS-InstanceProfile"
  role = aws_iam_role.Terraform-ECS-EC2-Role.name
  }

resource "aws_iam_role" "Terraform-ECS-Autoscalling-Role" {
  name = "Terraform-ECS-Autoscalling-Role"

   assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com","application-autoscaling.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }

  ]
}
EOF

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_policy" "Terraform-ECS-Autoscalling" {
  name        = "Terraform-ECS-Autoscalling-policy"
  description = "Policy to maintain container Ecommerce docker image"
  policy      =  file("Ecommerce-ECR-Policy.json")
}

resource "aws_iam_role_policy_attachment" "Terraform-ECS-Autoscalling" {
  role       = aws_iam_role.Terraform-ECS-Autoscalling-Role.name
  policy_arn = aws_iam_policy.Terraform-ECS-Autoscalling.arn
}


resource "aws_iam_role" "Terraform-ECS-Execution-Role" {
  name = "Terraform-ECS-Execution-Role"

   assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com","ecs.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }

  ]
}
EOF

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_policy" "Terraform-ECS-Execution-Role" {
  name        = "Terraform-ECS-Execution-Role-policy"
  description = "Policy to run container Ecommerce docker image"
  policy      =  file("Ecommerce-ECS-Execution.json")
}

resource "aws_iam_role_policy_attachment" "Terraform-ECS-Execution-Role" {
  role       = aws_iam_role.Terraform-ECS-Execution-Role.name
  policy_arn = aws_iam_policy.Terraform-ECS-Execution-Role.arn
  #policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

#AutoScalling
resource "aws_autoscaling_group" "AutoScallingGroup" {
    name = "myECSAutoScallingGroup"
    launch_configuration = aws_launch_configuration.ECSConfigruation.name
    vpc_zone_identifier = [var.subnet_primary_1, var.subnet_primary_2]
    min_size = 1
    max_size = var.autoscallingMaxSize
    desired_capacity = var.desiredCapacity
    health_check_type = "EC2"

}

resource "aws_launch_configuration" "ECSConfigruation" {
  image_id = var.ec2AMI
  instance_type = var.instanceType
  security_groups = [aws_security_group.Autoscalling.id]
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.ECS-InstanceProfile.arn
  key_name = var.keyName
  user_data = data.template_cloudinit_config.myECSUserData.rendered
  #user_data = "#!/bin/bash\necho ECS_CLUSTER=${var.clusterName} >> /etc/ecs/ecs.config"
}

resource "aws_appautoscaling_target" "AutoScallingTarget" {
  min_capacity       = var.desiredCapacity
  max_capacity       = var.autoscallingMaxSize
  #resource_id        = "service/${var.clusterName}/${aws_ecs_service.Service.name}"
  resource_id        = "service/ecommerceCluster/ecommerceService"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  role_arn = aws_iam_role.Terraform-ECS-Autoscalling-Role.arn
}

resource "aws_appautoscaling_policy" "ECS" {
  name               = "AStepPolicy"
  policy_type        = "StepScaling"
  resource_id         = aws_appautoscaling_target.AutoScallingTarget.id
  scalable_dimension = aws_appautoscaling_target.AutoScallingTarget.scalable_dimension
  service_namespace  = aws_appautoscaling_target.AutoScallingTarget.service_namespace

  step_scaling_policy_configuration {
    adjustment_type = "PercentChangeInCapacity"
    cooldown = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = 200
    }

  }
}

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





#Create ECS cluster
resource "aws_ecr_repository" "worker" {
    name  = "worker"
}



resource "aws_ecs_cluster" "Cluster" {
  name  = var.clusterName
  #capacity_providers = []
  }

resource "aws_ecs_task_definition" "TaskBlue" {
  family = "ecommerceTask"
  network_mode = "bridge"
  requires_compatibilities = ["EC2"]
  container_definitions = file("ecommerceContainerDefinition.json")
 # execution_role_arn = aws_iam_role.Terraform-ECS-Execution-Role.arn
}

resource "aws_ecs_service" "Service" {
  depends_on = [aws_lb_listener_rule.ALBListenerRule]
  task_definition = aws_ecs_task_definition.TaskBlue.arn
  name            = var.serviceName
  cluster         = aws_ecs_cluster.Cluster.arn
  launch_type     = "EC2"
  desired_count   = var.desiredCapacity
  #deployment_controller = "EXTERNAL"
  #iam_role        = aws_iam_role.Terraform-ECS-Execution-Role.arn
  #depends_on      = [aws_iam_role_policy.foo]

  #ordered_placement_strategy {
  #  type  = "binpack"
  #  field = "cpu"
  #}

  load_balancer {
    container_name   = var.conatinerName
    container_port   = var.containerPort
    target_group_arn = aws_lb_target_group.Blue.arn
}

  #placement_constraints {
  #  type       = "memberOf"
  #  expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  #{
}

output "ecommerceUTL" {
  value       = "http://${aws_lb.ALB.dns_name}:8080/polls"
}


#Error: InvalidParameterException: The target group with targetGroupArn
#arn:aws:elasticloadbalancing:eu-west-1:982779134822:targetgroup/myEcommerTargetGroupBlue/f69b4892aaaebb6d
#does not have an associated load balancer. "ecommerceService"