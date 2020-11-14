
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
  policy      =  file("iam-policy/Ecommerce-ECR-Policy.json")
}

resource "aws_iam_policy" "Terraform-Ecommerce-ECS" {
  name        = "Terraform-Ecommerce-ECS-policy"
  description = "Policy to run ECS on EC2"
  policy      =  file("iam-policy/Ecommerce-ECS-Policy.json")
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
  policy      =  file("iam-policy/Ecommerce-ECR-Policy.json")
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
  policy      =  file("iam-policy/Ecommerce-ECS-Execution.json")
}

resource "aws_iam_role_policy_attachment" "Terraform-ECS-Execution-Role" {
  role       = aws_iam_role.Terraform-ECS-Execution-Role.name
  policy_arn = aws_iam_policy.Terraform-ECS-Execution-Role.arn
  #policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

