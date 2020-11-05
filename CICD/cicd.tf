#CodeBuild role and policies
resource "aws_iam_role" "Terraform-CodeBuild-Ecommerce" {
  name = "Terraform-CodeBuild-Ecommerce"

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

resource "aws_iam_policy" "Terraform-Ecommerce-ECR-policy" {
  name        = "Terraform-Ecommerce-ECR-policy"
  description = "Policy to maintain container Ecommerce docker image"
  policy      =  file("Ecommerce-ECR-Policy.json")
}

resource "aws_iam_role_policy_attachment" "Terraform-Ecommerce-CB-ECR-policy-attach" {
  role       = aws_iam_role.Terraform-CodeBuild-Ecommerce.name
  policy_arn = aws_iam_policy.Terraform-Ecommerce-ECR-policy.arn
}

resource "aws_iam_policy" "Terraform-Ecommerce-S3-policy" {
  name        = "Terraform-Ecommerce-S3-policy"
  description = "Policy to access S3 for the Ecommerce CICD"
  policy      =  file("Ecommerce-S3-Policy.json")
}

resource "aws_iam_role_policy_attachment" "Terraform-Ecommerce-CB-S3-policy-attach" {
  role       = aws_iam_role.Terraform-CodeBuild-Ecommerce.name
  policy_arn = aws_iam_policy.Terraform-Ecommerce-S3-policy.arn
}

resource "aws_iam_policy" "Terraform-Ecommerce-CW-policy" {
  name        = "Terraform-Ecommerce-CW-policy"
  description = "xxx"
  policy      =  file("Ecommerce-CW-Policy.json")
}

resource "aws_iam_role_policy_attachment" "Terraform-Ecommerce-CB-CW-policy-attach" {
  role       = aws_iam_role.Terraform-CodeBuild-Ecommerce.name
  policy_arn = aws_iam_policy.Terraform-Ecommerce-CW-policy.arn
}


#CodePipleline role and policies
resource "aws_iam_role" "Terraform-CodePipleline-Ecommerce" {
  name = "Terraform-CodePipeline-Ecommerce"

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

resource "aws_iam_policy" "Terraform-Ecommerce-CP-policy" {
  name        = "Terraform-Ecommerce-CodePipeline-policy"
  description = "Policy to used CodePipeline for Ecommerce cicd"
  policy      =  file("Ecommerce-CP-Policy.json")
}

resource "aws_iam_role_policy_attachment" "Terraform-Ecommerce-CP-CW-policy-attach" {
  role       = aws_iam_role.Terraform-CodePipleline-Ecommerce.name
  policy_arn = aws_iam_policy.Terraform-Ecommerce-CP-policy.arn
}

resource "aws_iam_role_policy_attachment" "Terraform-Ecommerce-CP-S3-policy-attach" {
  role       = aws_iam_role.Terraform-CodePipleline-Ecommerce.name
  policy_arn = aws_iam_policy.Terraform-Ecommerce-S3-policy.arn
}

resource "aws_iam_role_policy_attachment" "Terraform-Ecommerce-CP-ECR-policy-attach" {
  role       = aws_iam_role.Terraform-CodePipleline-Ecommerce.name
  policy_arn = aws_iam_policy.Terraform-Ecommerce-ECR-policy.arn
}

#Artifact and Cache S3 Bucket
resource "aws_s3_bucket" "Artifact_bucket" {
  bucket = join("", [var.environment,"-","cicd-ecommerce-artifact"])
  acl    = "private"

  tags = {
    Name        = "Artifact"
    Application = "MyEcommerce"
    Environment = var.environment
  }
}

resource "aws_s3_bucket" "Cache_bucket" {
  bucket = join("", [var.environment,"-","cicd-ecommerce-cache"])
  acl    = "private"

  tags = {
    Name        = "Cache"
    Application = "MyEcommerce"
    Environment = var.environment
  }
}

#Code Build

resource "aws_codebuild_project" "ecommerce-build" {
  name          = "ecommerce-build"
  description   = "ecommerce build"
  build_timeout = "5"
  queued_timeout = "5"
  service_role  = aws_iam_role.Terraform-CodeBuild-Ecommerce.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type     = "S3"
    location = aws_s3_bucket.Cache_bucket.bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode = true


   #environment_variable {
    #  name  = "SOME_KEY1"
    #  value = "SOME_VALUE1"
    #}

    #environment_variable {
    #  name  = "SOME_KEY2"
    #  value = "SOME_VALUE2"
    #  type  = "PARAMETER_STORE"
    #}

  }

  #      Location: !ImportValue CICD-IAM-Buckets-eu-west-1-CacheBucket
  #      Type: S3


  #  cache {
  #    type  = "LOCAL"
  #    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  #  }


  logs_config {
    cloudwatch_logs {
      group_name  = "ecommere-codepipeline"
      stream_name = "codepipeline"
    }
  }

  source {
    type            = "CODEPIPELINE"
    buildspec       = "buildspec.yml"
  }

 # vpc_config {
 #   vpc_id = aws_vpc.example.id

  #  subnets = [
  #    aws_subnet.example1.id,
  #    aws_subnet.example2.id,
  #  ]

  #  security_group_ids = [
  #    aws_security_group.example1.id,
  #    aws_security_group.example2.id,
  #  ]
  #}

  tags = {
    Application = "myEcommerce"
    Environment = var.environment
  }
}

#CodePipeline

resource "aws_codepipeline" "Ecommerce-codepipeline" {
  name     = "Ecommerce-codepipeline"
  role_arn = aws_iam_role.Terraform-CodePipleline-Ecommerce.arn

  artifact_store {
    location = aws_s3_bucket.Artifact_bucket.bucket
    type     = "S3"

    #encryption_key {
    #  id   = data.aws_kms_alias.s3kmskey.arn
    #  type = "KMS"
    #}
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      #ConnectionArn: arn:aws:codestar-connections:eu-west-1:982779134822:connection/b14693e5-34ce-4e19-a39f-9e11230097ff
      #FullRepositoryId: fwohnrau/eCommerce-django
      #RepositoryId: !Join ['', [ !Ref GithubUser,'/', !Ref GithubRepo]]
      #BranchName: master


      configuration = {
        ConnectionArn = var.myGithubCodeStarSourceConnectionArn
        FullRepositoryId: var.EcommerceRepository
        BranchName: var.codeBranch

        #Owner      = "my-organization"
        #Repo       = "test"
        #Branch     = "master"
        #OAuthToken = var.github_token
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.ecommerce-build.name
      }
    }
  }
}
