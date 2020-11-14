#CodeBuild role and policies
resource "aws_iam_role" "Ecommerce-CodeBuild" {
  name = "${var.rolePrefixName}CodeBuild"

   assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
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

resource "aws_iam_policy" "Ecommerce-ECR" {
  name        = "${var.rolePrefixName}ECR"
  description = "Policy to maintain container Ecommerce docker image"
  policy      =  file("iam-policy/Ecommerce-ECR-Policy.json")
}

resource "aws_iam_role_policy_attachment" "Ecommerce-ECR-CB" {
  role       = aws_iam_role.Ecommerce-CodeBuild.name
  policy_arn = aws_iam_policy.Ecommerce-ECR.arn
}

resource "aws_iam_policy" "Ecommerce-S3" {
  name        = "${var.rolePrefixName}S3"
  description = "Policy to access S3 for the Ecommerce CICD"
  policy      =  file("iam-policy/Ecommerce-S3-Policy.json")
}

resource "aws_iam_role_policy_attachment" "Ecommerce-S3-CB" {
  role       = aws_iam_role.Ecommerce-CodeBuild.name
  policy_arn = aws_iam_policy.Ecommerce-S3.arn
}

resource "aws_iam_policy" "Ecommerce-CW" {
  name        = "${var.rolePrefixName}CW"
  description = "xxx"
  policy      =  file("iam-policy/Ecommerce-CW-Policy.json")
}

resource "aws_iam_role_policy_attachment" "Ecommerce-CW-CB" {
  role       = aws_iam_role.Ecommerce-CodeBuild.name
  policy_arn = aws_iam_policy.Ecommerce-CW.arn
}


#CodePipleline role and policies
resource "aws_iam_role" "CodePipleline-Ecommerce" {
  name = "${var.rolePrefixName}CodePipeline"

   assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
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

resource "aws_iam_policy" "Ecommerce-CP" {
  name        = "Terraform-Ecommerce-CodePipeline-policy"
  description = "Policy to used CodePipeline for Ecommerce cicd"
  policy      =  file("iam-policy/Ecommerce-CP-Policy.json")
}

resource "aws_iam_role_policy_attachment" "Ecommerce-CP-CW" {
  role       = aws_iam_role.CodePipleline-Ecommerce.name
  policy_arn = aws_iam_policy.Ecommerce-CP.arn
}

resource "aws_iam_role_policy_attachment" "Ecommerce-CP-S3" {
  role       = aws_iam_role.CodePipleline-Ecommerce.name
  policy_arn = aws_iam_policy.Ecommerce-S3.arn
}

resource "aws_iam_role_policy_attachment" "Ecommerce-CP-ECR" {
  role       = aws_iam_role.CodePipleline-Ecommerce.name
  policy_arn = aws_iam_policy.Ecommerce-ECR.arn
}

resource "aws_iam_role" "Ecommerce-CodeDeploy" {
  name = "${var.rolePrefixName}CodeDeploy"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "Ecommerce-CD-1" {
  role       = aws_iam_role.Ecommerce-CodeDeploy.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

resource "aws_iam_role_policy_attachment" "Ecommerce-CD-2" {
  role       = aws_iam_role.Ecommerce-CodeDeploy.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}