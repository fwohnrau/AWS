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


variable "domaine_name" {
  default = "myecommerce.com"
}