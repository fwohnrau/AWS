#Create Security Groups
resource "aws_security_group" "Terraform-Autoscalling-EC2-SG"{
  name  = "Terraform-Autoscalling-EC2-SG"
  vpc_id = var.vpc

  ingress {
    protocol = "tcp"
    from_port = 8080
    to_port = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "tcp"
    from_port = 31000
    to_port = 61000
    #CidrIp = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "Terraform-myEcommerce-ALB-SG"{
  name  = "Terraform-myEcommerce-ALB-SG"
  vpc_id = var.vpc

  ingress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
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

resource "aws_iam_policy" "Terraform-Ecommerce-ECS-ECR-policy" {
  name        = "Terraform-Ecommerce-ECS-ECR-policy"
  description = "Policy to maintain container Ecommerce docker image"
  policy      =  file("Ecommerce-ECR-Policy.json")
}

resource "aws_iam_policy" "Terraform-Ecommerce-ECS-policy" {
  name        = "Terraform-Ecommerce-ECS-policy"
  description = "Policy to run ECS on EC2"
  policy      =  file("Ecommerce-ECS-Policy.json")
}

resource "aws_iam_role_policy_attachment" "Terraform-Ecommerce-ECS-ECR-policy-Attachement" {
  role       = aws_iam_role.Terraform-ECS-EC2-Role.name
  policy_arn = aws_iam_policy.Terraform-Ecommerce-ECS-ECR-policy.arn
}

resource "aws_iam_role_policy_attachment" "Terraform-Ecommerce-ECS-policy-Attachement" {
  role       = aws_iam_role.Terraform-ECS-EC2-Role.name
  policy_arn = aws_iam_policy.Terraform-Ecommerce-ECS-policy.arn
}

resource "aws_iam_instance_profile" "Terraform-ECS-InstanceProfile"{
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

resource "aws_iam_policy" "Terraform-ECS-Autoscalling-policy" {
  name        = "Terraform-ECS-Autoscalling-policy"
  description = "Policy to maintain container Ecommerce docker image"
  policy      =  file("Ecommerce-ECR-Policy.json")
}

resource "aws_iam_role_policy_attachment" "Terraform-ECS-Autoscalling-policy-Attachement" {
  role       = aws_iam_role.Terraform-ECS-Autoscalling-Role.name
  policy_arn = aws_iam_policy.Terraform-ECS-Autoscalling-policy.arn
}

#AutoScalling
resource "aws_autoscaling_group" "myECSAutoScallingGroup" {
    name = "myECSAutoScallingGroup"
    vpc_zone_identifier = [var.subnet_primary_1, var.subnet_primary_2]
    min_size = 1
    max_size = var.autoscallingMaxSize
    desired_capacity = var.desiredCapacity
    launch_configuration = aws_launch_configuration.myECSLaunchConfigruation.name
}

resource "aws_launch_configuration" "myECSLaunchConfigruation" {
  image_id = var.ec2AMI
  instance_type = var.instanceType
  associate_public_ip_address = true
  security_groups = [aws_security_group.Terraform-Autoscalling-EC2-SG.id]
  iam_instance_profile = aws_iam_instance_profile.Terraform-ECS-InstanceProfile.arn
  key_name = var.keyName
  user_data = data.template_cloudinit_config.myECSUserData.rendered
}

resource "aws_appautoscaling_target" "myECSAutoScallingTarget" {
  max_capacity       = var.desiredCapacity
  min_capacity       = var.autoscallingMaxSize
  resource_id        = "service/${var.clusterName}/${aws_ecs_service.Ecommerce-Service.id}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  role_arn = aws_iam_role.Terraform-ECS-Autoscalling-Role.arn
}

resource "aws_appautoscaling_policy" "myECSAutoScallingPolicy" {
  name               = "AStepPolicy"
  policy_type        = "StepsScaling"
  resource_id         = aws_appautoscaling_target.myECSAutoScallingTarget.id
  scalable_dimension = aws_appautoscaling_target.myECSAutoScallingTarget.scalable_dimension
  service_namespace  = aws_appautoscaling_target.myECSAutoScallingTarget.service_namespace

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
resource "aws_lb" "myEcommerALB" {
  name               = "myEcommerALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.Terraform-myEcommerce-ALB-SG.id]
  subnets            = [var.subnet_primary_1, var.subnet_primary_2]

  enable_deletion_protection = false

  tags = {
    Environment = var.environment
  }
}

resource "aws_lb_listener" "myEcommerALBListener" {
  load_balancer_arn = aws_lb.myEcommerALB.arn
    #port = "443"
    port = "80"
    protocol = "HTTP"
    #ssl_policy = "ELBSecurityPolicy-2016-08"
    #certificate_arn = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.myEcommerTargetGroupBlue.arn
  }
}

resource "aws_lb_listener_rule" "myEcommerALBListenerRule" {
  listener_arn = aws_lb_listener.myEcommerALBListener.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.myEcommerTargetGroupGreen.arn
  }

  condition {
    path_pattern {
      values = ["/polls*","/admin*"]
    }
  }

  #condition {
  #  host_header {
  #    values = ["example.com"]
  #  }
  #}
}


resource "aws_lb_target_group" "myEcommerTargetGroupBlue" {
  name     = "myEcommerTargetGroupBlue"
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

resource "aws_lb_target_group" "myEcommerTargetGroupGreen" {
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


#Create ECS cluster
resource "aws_ecs_cluster" "myECSCluster" {
  name  = var.clusterName
  #capacity_providers = []
  }


resource "aws_ecs_task_definition" "ecommerceTaskBlue" {
  family = "ecommerceTask"
  network_mode = "bridge"
  requires_compatibilities = ["EC2"]
  container_definitions = file("ecommerceContainerDefinition.json")
}





resource "aws_ecs_service" "Ecommerce-Service" {
  name            = "Ecommerce-Service"
  cluster         = aws_ecs_cluster.myECSCluster.id
  task_definition = aws_ecs_task_definition.ecommerceTaskBlue.arn
  desired_count   = 2
  #deployment_controller = "EXTERNAL"
  #iam_role        = aws_iam_role.foo.arn
  #depends_on      = [aws_iam_role_policy.foo]

  #ordered_placement_strategy {
  #  type  = "binpack"
  #  field = "cpu"
  #}

  #load_balancer {
  #  target_group_arn = aws_lb_target_group.myEcommerTargetGroupBlue.arn
  #  container_name   = var.conatinerName
  #  container_port   = 8080
  #}

  #placement_constraints {
  #  type       = "memberOf"
  #  expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  #}
}