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

variable "ecommerce_docker_image" {
  default = "982779134822.dkr.ecr.eu-west-1.amazonaws.com/mydjango-ecommerce"
}

variable "myGithubCodeStarSourceConnectionArn" {
  default = "arn:aws:codestar-connections:eu-west-1:982779134822:connection/b14693e5-34ce-4e19-a39f-9e11230097ff"
}


variable "clusterName" {
  default = "ecommerceCluster"
}

variable "serviceName" {
  default = "ecommerceService"
}

variable logGroup {
  default = "Terraform-Ecommerce"
}

variable "EcommerceRepository" {
  default = "fwohnrau/eCommerce-django"
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

variable "codeBranch" {
  default = "master"
}

variable "instanceType" {
  default = "t2.micro"
}

variable "ec2AMI" {
  default = "ami-a1491ad2"
}

variable "keyName" {
  #default = "MyECSEC2KeyPair"
  default = "UdemmyEC2KeyPair"
}

variable "autoscallingMaxSize" {
  default = 2
}

variable "desiredCapacity" {
  default = 2
}

variable "minCapacity" {
  default = 1
}

