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
  region  = var.region_primary
}



#$ export AWS_SECRET_ACCESS_KEY=...
#$ export AWS_ACCESS_KEY_ID=..
#$ export AWS_DEFAULT_REGION=eu-west-1