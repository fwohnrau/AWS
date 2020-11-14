#Create ECS cluster
#resource "aws_ecr_repository" "worker" {
#    name  = "worker"
#}

resource "aws_ecs_cluster" "Cluster" {
  name  = var.clusterName
  #capacity_providers = []
  }

resource "aws_ecs_task_definition" "TaskBlue" {
  family = "ecommerceTask"
  network_mode = "bridge"
  requires_compatibilities = ["EC2"]
  container_definitions = file("container/ecommerceContainerDefinition.json")
 # execution_role_arn = aws_iam_role.Terraform-ECS-Execution-Role.arn
}

resource "aws_ecs_service" "eCommerceService" {
  depends_on = [aws_lb_listener_rule.ALBListenerRule]
  task_definition = aws_ecs_task_definition.TaskBlue.arn
  name            = var.serviceName
  cluster         = aws_ecs_cluster.Cluster.arn
  launch_type     = "EC2"
  desired_count   = var.desiredCapacity

  deployment_controller {
    type = "CODE_DEPLOY"
  }
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