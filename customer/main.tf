terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "eu-west-1"
}

module "customerRDS"{
  source = "../modules/RDS"

  environment = "dev"
  vpc = var.vpc
  subnet_private_1 = var.subnet_private_1
  subnet_private_2 = var.subnet_private_2
  rdsDbPort = 3306
  rdsDbName = "CustomerDB"
  rdsAdminUser = "admin1"
  rdsAdminPwd = "admin1234"
  rdsLambdaDBSetupName = "customerDBSetup"
  rdsLambdaDBAPIName = "CustoermDBAPI"
  rdsLambdaCodeS3 = var.lambdaCodeS3
  rdsLambdaCodeDBSetup = var.rdsLambdaCodeDBSetup
  rdsLambdaCodeDBAPI = var.rdsLambdaCodeAPI
  rolePrefixName = var.rolePrefix
  lambdaHandlerDBSetup = var.lamdbaHandlerDBSetup
  lambdaHandlerDBAPI = var.lamdbaHandlerDBAPI
  microService = "Customer"
  apiName = "RDSAPI"
}






