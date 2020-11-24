variable "environment" {
  description = "Environment - prod/test/dev"
  default = "dev"
}

variable "region_primary" {
  default = "eu-west-1"
}

variable "vpc" {
  default = "vpc-0f2516a17f1b3cafb"
}

variable "subnet_primary_1" {
  default = "subnet-0139340dd01e4119d"
}

variable "subnet_primary_2" {
  default = "subnet-084758bad445ffd0b"
}

variable "ecrImage" {
  description = "ECR image"
}

variable "myGithubCodeStarSourceConnectionArn" {
  description = "Github CodeStar Source Connection"
}

variable "EcommerceRepository" {
  description = "Github repository"
}

variable "codeBranch" {
  description = "code branch"
}

variable "appName" {
  description = "Application name"
}


variable "serviceName" {
  description = "ECS service name"

}



variable "continerName" {
  description = "Container name"
}


variable "containerPort" {
  description = "Container port"
  default = 8080
}

variable "hostPort" {
  description = "Host port"
  default = 8080
}


variable "instanceType" {
  description = "Host port>"
  default = "t2.micro"
}

variable "ec2AMI" {
  #default = "ami-a1491ad2"
  description = "Host port>"
  default ="ami-0c9ef930279337028"
}

variable "keyName" {
  #default = "MyECSEC2KeyPair"
  description = "Host port>"
  default = "UdemmyEC2KeyPair"
}

variable "autoscallingMaxSize" {
  description = "Host port>"
  default = 2
}

variable "desiredCapacity" {
  description = "Host port>"
  default = 1
}

variable "minCapacity" {
  description = "Host port>"
  default = 1
}