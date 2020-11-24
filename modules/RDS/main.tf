terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

resource "random_password" "password" {
  length = 10
  special = true
  override_special = "_%@"
}

resource "aws_secretsmanager_secret" "AdminPwdSecret" {
  name = "${var.rdsDbName}_admin1"
  tags = {
    username="${var.rdsDbName}_admin"
    password= random_password.password.result
  }
}

#data "aws_secretsmanager_secret_version" "AdminPwdSecret" {
#  depends_on = [aws_secretsmanager_secret.AdminPwdSecret]
#  # Fill in the name you gave to your secret
#  secret_id = "${var.rdsDbName}_admin"
#}

#locals {
#  AdminPwd = jsondecode(
#    data.aws_secretsmanager_secret_version.AdminPwdSecret.secret_string
#  )
#}


resource "aws_iam_role" "iam_for_lambda" {
  name = "${var.rolePrefixName}RDSlambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

#add policy arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
resource aws_iam_role_policy_attachment "lambda_exec"{
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#Security Groups
resource "aws_security_group" "rds_cust_sg" {
    vpc_id      = var.vpc

    ingress {
        protocol        = "tcp"
        from_port       = var.rdsDbPort
        to_port         = var.rdsDbPort
        cidr_blocks     = ["0.0.0.0/0"]
        #security_groups = [aws_security_group.ecs_sg.id]
    }

    egress {
        from_port       = 0
        to_port         = 65535
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}

#RDS Instance
resource "aws_db_subnet_group" "db_subnet_group" {
    subnet_ids  = [var.subnet_private_1,var.subnet_private_2]
}


resource "aws_db_instance" "RDSInstance" {
    identifier                = var.rdsDBType
    allocated_storage         = 5
    backup_retention_period   = 2
    #backup_window             = var.rdsBackupWindow
    #maintenance_window        = var.rdsMaintenanceWindow
    multi_az                  = false
    engine                    = "mysql"
    engine_version            = "5.7"
    instance_class            = var.rdsInstanceType
    name                      = var.rdsDbName
    username                  = var.rdsAdminUser
    password                  = random_password.password.result
    port                      = var.rdsDbPort
    db_subnet_group_name      = aws_db_subnet_group.db_subnet_group.id
    vpc_security_group_ids    = [aws_security_group.rds_cust_sg.id]
    skip_final_snapshot       = true
    final_snapshot_identifier = "${var.rdsDbName}-final"
    publicly_accessible       = false
}


#Lambda

resource "aws_lambda_function" "rds_DBSetup" {
  #filename      = var.rdsLambdaCode
  function_name = var.rdsLambdaDBSetupName
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = var.lambdaHandlerDBSetup

  timeout = 30

  runtime = "python3.8"

  s3_bucket = var.rdsLambdaCodeS3
  s3_key = var.rdsLambdaCodeDBSetup

  #source_code_hash = filebase64sha256(var.rdsLambdaCode)

  #environment {
  #  variables = {
  #    foo = "bar"
  #  }
  #}
}

resource "aws_lambda_function" "rds_DBAPI" {
  #filename      = var.rdsLambdaCode
  function_name = var.rdsLambdaDBAPIName
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = var.lambdaHandlerDBAPI

  timeout = 30

  runtime = "python3.8"

  s3_bucket = var.rdsLambdaCodeS3
  s3_key = var.rdsLambdaCodeDBAPI

  #source_code_hash = filebase64sha256(var.rdsLambdaCode)

  #environment {
  #  variables = {
  #    foo = "bar"
  #  }
  #}
}

#Web API

resource "aws_api_gateway_rest_api" "RDSAPI" {
  name        = "${var.apiName}-${var.microService}"
  description = "RDS API for ${var.microService}"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "RDSAPI" {
  rest_api_id = aws_api_gateway_rest_api.RDSAPI.id
  parent_id   = aws_api_gateway_rest_api.RDSAPI.root_resource_id
  path_part   = var.microService
}

resource "aws_api_gateway_method" "RDSAPIGET" {
  rest_api_id   = aws_api_gateway_rest_api.RDSAPI.id
  resource_id   = aws_api_gateway_resource.RDSAPI.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "RDSBAPI" {
  rest_api_id          = aws_api_gateway_rest_api.RDSAPI.id
  resource_id          = aws_api_gateway_resource.RDSAPI.id
  http_method          = aws_api_gateway_method.RDSAPIGET.http_method
  type                 = "AWS_PROXY"
  uri                  = aws_lambda_function.rds_DBAPI.invoke_arn
  integration_http_method = "POST"
}

resource "aws_api_gateway_method" "RDSBAPI_root" {
   rest_api_id   = aws_api_gateway_rest_api.RDSAPI.id
   resource_id   = aws_api_gateway_rest_api.RDSAPI.root_resource_id
   http_method   = "ANY"
   authorization = "NONE"
}

resource "aws_api_gateway_integration" "RDSBAPI_root" {
   rest_api_id = aws_api_gateway_rest_api.RDSAPI.id
   resource_id = aws_api_gateway_method.RDSBAPI_root.resource_id
   http_method = aws_api_gateway_method.RDSBAPI_root.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.rds_DBAPI.invoke_arn
}


resource "aws_api_gateway_deployment" "RDSAPI" {
  depends_on = [
     aws_api_gateway_integration.RDSBAPI,
     aws_api_gateway_integration.RDSBAPI_root
   ]

  rest_api_id = aws_api_gateway_rest_api.RDSAPI.id
  stage_name  = var.environment

  variables = {
    "environment" = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lambda_permission" "RDSAPI" {
   statement_id  = "AllowAPIGatewayInvoke"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.rds_DBAPI.function_name
   principal     = "apigateway.amazonaws.com"

   # The "/*/*" portion grants access from any method on any resource
   # within the API Gateway REST API.
   source_arn = "${aws_api_gateway_rest_api.RDSAPI.execution_arn}/*/*"
}
