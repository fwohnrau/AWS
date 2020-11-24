
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
  depends_on = [aws_ecs_service.eCommerceService]
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

