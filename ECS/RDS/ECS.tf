#https://medium.com/@paweldudzinski/creating-aws-ecs-cluster-of-ec2-instances-with-terraform-893c15d1116

resource "aws_security_group" "ecs_sg" {
    vpc_id      = var.vpc

    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    ingress {
        from_port       = 443
        to_port         = 443
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    egress {
        from_port       = 0
        to_port         = 65535
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "rds_sg" {
    vpc_id      = var.vpc

    ingress {
        protocol        = "tcp"
        from_port       = 3306
        to_port         = 3306
        cidr_blocks     = ["0.0.0.0/0"]
        security_groups = [aws_security_group.ecs_sg.id]
    }

    egress {
        from_port       = 0
        to_port         = 65535
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}

data "aws_iam_policy_document" "ecs_agent" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_agent" {
  name               = "ecs-agent"
  assume_role_policy = data.aws_iam_policy_document.ecs_agent.json
}


resource "aws_iam_role_policy_attachment" "ecs_agent" {
  role       = aws_iam_role.ecs_agent.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_agent" {
  name = "ecs-agent"
  role = aws_iam_role.ecs_agent.name
}

resource "aws_launch_configuration" "ecs_launch_config" {
    #image_id             = "ami-094d4d00fd7462815"
    image_id              = var.ec2AMI
    iam_instance_profile = aws_iam_instance_profile.ecs_agent.name
    security_groups      = [aws_security_group.ecs_sg.id]
    user_data            = "#!/bin/bash\necho ECS_CLUSTER=my-cluster >> /etc/ecs/ecs.config"
    instance_type        = "t2.micro"
}

resource "aws_autoscaling_group" "failure_analysis_ecs_asg" {
    name                      = "asg"
    vpc_zone_identifier       = [var.subnet_primary_1, var.subnet_primary_2]
    launch_configuration      = aws_launch_configuration.ecs_launch_config.name

    desired_capacity          = 2
    min_size                  = 1
    max_size                  = 10
    health_check_grace_period = 300
    health_check_type         = "EC2"
}

#resource "aws_db_subnet_group" "db_subnet_group" {
#    subnet_ids  = "${var.subnet_primary_1}"
#}

#resource "aws_db_instance" "mysql" {
#    identifier                = "mysql"
#    allocated_storage         = 5
#    backup_retention_period   = 2
#    backup_window             = "01:00-01:30"
#    maintenance_window        = "sun:03:00-sun:03:30"
#    multi_az                  = true
#    engine                    = "mysql"
#    engine_version            = "5.7"
#    instance_class            = "db.t2.micro"
#    name                      = "worker_db"
#    username                  = "worker"
#    password                  = "worker"
#    port                      = "3306"
#    db_subnet_group_name      = aws_db_subnet_group.db_subnet_group.id
#    vpc_security_group_ids    = [aws_security_group.rds_sg.id, aws_security_group.ecs_sg.id]
#    skip_final_snapshot       = true
#    final_snapshot_identifier = "worker-final"
#    publicly_accessible       = true
#}



#data "aws_ecr_image" "service_image" {
#  repository_name = var.ecommerce_docker_image
#  image_tag       = "latest"
#}

#resource "aws_ecr_repository" "worker" {
#    name  = "worker"


#}

resource "aws_ecs_cluster" "ecs_cluster" {
    name  = "my-cluster"
}

data "template_file" "task_definition_template" {
    template = file("task_definition.json.tpl")
    vars = {
      #REPOSITORY_URL = replace("aws_ecr_repository.worker.repository_url", "https://", "")
      REPOSITORY_URL = "982779134822.dkr.ecr.eu-west-1.amazonaws.com/mydjango-ecommerce"
  }
}

resource "aws_ecs_task_definition" "task_definition" {
  family                = "worker"
  container_definitions = data.template_file.task_definition_template.rendered
}

resource "aws_ecs_service" "worker" {
  name            = "worker"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 2
}

#output "mysql_endpoint" {
#    value = aws_db_instance.mysql.endpoint
#}

#output "ecr_repository_worker_endpoint" {
#    value = aws_ecr_repository.worker.repository_url
#}