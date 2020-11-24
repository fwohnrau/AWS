
#VPC
variable "vpc" {
  default = "vpc-0f2516a17f1b3cafb"
}

#Subnet
variable "subnet_public_1" {
  default = "subnet-0139340dd01e4119d"
}

variable "subnet_public_2" {
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

variable "rdsAdminUser" {
  default = "admin"
}

#To be moved to secret management.
variable "rdsAdminPwd" {
  default = "admin1234"
}

#lamdba

variable "lambdaCodeS3" {
  default = "mycode-cloudformation"
}

variable "rdsLambdaName" {
  default = "custDBlambdaGet"
}

variable "rdsLambdaCodeDBSetup" {
  default = "Select.zip"
}

variable "rdsLambdaCodeAPI" {
  default = "Test.zip"
}

variable "lamdbaHandlerDBSetup" {
  default = "dbsetup.lambda_handler"
}

variable "lamdbaHandlerDBAPI" {
  default = "lambdaRDSTest.lambda_handler"
}

variable "rolePrefix" {
  default = "Terraform-Customer"
}


