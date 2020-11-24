variable "environment" {
  description = "Environment - prod/test/dev"
  default = "dev"
}

variable "region_primary" {
  default = "eu-west-1"
}

#VPC

variable "vpc" {
  default = "vpc-0f2516a17f1b3cafb"
}

#Subnet

variable "subnet_primary_1" {
  default = "subnet-0139340dd01e4119d"
}

variable "subnet_primary_2" {
  default = "subnet-084758bad445ffd0b"
}

variable "subnet_private_1" {
  default = "subnet-0139340dd01e4119d"
}

variable "subnet_private_2" {
  default = "subnet-084758bad445ffd0b"
}


#RDS

variable "rdsInstanceType" {
  default = "db.t2.micro"
}

variable "rdsDBType" {
  default = "mysql"
}

variable "rdsBackupWindow" {
  default = "01:00-01:30"
}

variable "rdsMaintenanceWindow" {
  default = "sun:03:00-sun:03:30"
}

variable "rdsDbPort" {
  default = "3306"
}

variable "rdsDbName" {
  default = "CustomerDB"
}

variable "rdsCustAdminUser" {
  default = "admin"
}

#To be moved to secret management.
variable "rdsAdminPwd" {
  default = "admin1234"
}

#lamdba

variable "rdsLambdaName" {
  default = "custDBlambdaGet"
}

variable "rdsLambdaCodeS3" {
  default = "mycode-cloudformation"
}

variable "rdsLambdaCode" {
  default = "Select.zip"
}


#Container

variable "ecommerce_docker_image" {
  default = "982779134822.dkr.ecr.eu-west-1.amazonaws.com/mydjango-ecommerce"
}

variable "myGithubCodeStarSourceConnectionArn" {
  default = "arn:aws:codestar-connections:eu-west-1:982779134822:connection/b14693e5-34ce-4e19-a39f-9e11230097ff"
}

variable "EcommerceRepository" {
  default = "fwohnrau/eCommerce-django"
}

variable "codeBranch" {
  default = "master"
}

variable "appName" {
  default = "myEcommerce"
}

variable "rolePrefixName" {
  default = "Terraform-myEcommerce"
}


variable "clusterName" {
  default = "ecommerceCluster"
}

variable "serviceName" {
  default = "ecommerceService"
}

variable logGroup {
  default = "ecommerceTask"
}


variable "conatinerName" {
  default = "ecommerceContainer"
}


variable "containerPort" {
  default = 8080
}

variable "hostPort" {
  default = 8080
}


variable "instanceType" {
  default = "t2.micro"
}

variable "ec2AMI" {
  #default = "ami-a1491ad2"
  default ="ami-0c9ef930279337028"
}

variable "keyName" {
  #default = "MyECSEC2KeyPair"
  default = "UdemmyEC2KeyPair"
}

variable "autoscallingMaxSize" {
  default = 2
}

variable "desiredCapacity" {
  default = 1
}

variable "minCapacity" {
  default = 1
}


