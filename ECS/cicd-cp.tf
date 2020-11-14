#Code Build

resource "aws_codebuild_project" "ecommerce-build" {
  name          = "ecommerce-build"
  description   = "ecommerce build"
  build_timeout = "5"
  queued_timeout = "5"
  service_role  = aws_iam_role.Ecommerce-CodeBuild.arn

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

#CodeDeploy
resource "aws_codedeploy_app" "Ecommerce-App" {
  compute_platform = "ECS"
  name             = var.appName
}

resource "aws_codedeploy_deployment_group" "Ecommerce-App" {
  app_name               = aws_codedeploy_app.Ecommerce-App.name
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  deployment_group_name  = "DG1"
  service_role_arn       = aws_iam_role.Ecommerce-CodeDeploy.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = var.clusterName
    service_name = var.serviceName
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.ALBListener.arn]
      }

      target_group {
        name = aws_lb_target_group.Blue.name
      }

      target_group {
        name = aws_lb_target_group.Green.name
      }
    }
  }
}



#CodePipeline

resource "aws_codepipeline" "Ecommerce-codepipeline" {
  name     = "Ecommerce-codepipeline"
  role_arn = aws_iam_role.CodePipleline-Ecommerce.arn





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
