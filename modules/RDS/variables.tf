variable "environment" {
  description = "Environment - prod/test/dev"
}

variable "microService" {
  description = "Name of the microservice (e-g Customer, Order, Reporting, ..."
}

#VPC

variable "vpc" {
  description = "VPC id"

}

#Subnet

variable "subnet_private_1" {
  description = "Subnet Private ID AZ1"
}

variable "subnet_private_2" {
  description = "Subnet Private ID AZ2"
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
  description = "RDS port number"
  default = "3306"
}

variable "rdsDbName" {
  description = "RDS Instance Name"
}

variable "rdsAdminUser" {
  description = "RDS admin user"
}

#To be moved to secret management.
variable "rdsAdminPwd" {
  description = "RDS admin password"
}

#lamdba

variable "rdsLambdaDBSetupName" {
  description = "Lamdba Name to setup RDS DB objects"
}

  variable "rdsLambdaDBAPIName" {
  description = "Lamdba Name to manage RDS API"
}


variable "rdsLambdaCodeS3" {
  description = "S3 bucket for lambda code"
}

variable "rdsLambdaCodeDBSetup" {
  description = "ZIP File name containing lamdba code for DB setup"
}

variable "rdsLambdaCodeDBAPI" {
  description = "ZIP File name containing lamdba code for RDS API"
}

variable "lambdaHandlerDBSetup" {
  description = "lamdba function DB setup handler"
}

variable "lambdaHandlerDBAPI" {
  description = "lamdba function DB API handler"
}

#IAM
variable "rolePrefixName" {
  description = "Prefix for IAM objects name"
}

#API
variable "apiName" {
  description = "Name of API used to query RDS database"
}

