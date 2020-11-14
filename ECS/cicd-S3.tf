#Artifact and Cache S3 Bucket
resource "aws_s3_bucket" "Artifact_bucket" {
  bucket = join("", [var.environment,"-","cicd-ecommerce-artifact"])
  acl    = "private"

  tags = {
    Name        = "Artifact"
    Application = "MyEcommerce"
    Environment = var.environment
  }
}

resource "aws_s3_bucket" "Cache_bucket" {
  bucket = join("", [var.environment,"-","cicd-ecommerce-cache"])
  acl    = "private"

  tags = {
    Name        = "Cache"
    Application = "MyEcommerce"
    Environment = var.environment
  }
}

#