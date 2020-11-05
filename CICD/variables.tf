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
  default = "subnet-0139340dd01e4119d"
}

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