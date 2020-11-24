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

