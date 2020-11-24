resource "aws_lambda_function" "test_lambda" {
  #filename      = var.rdsLambdaCode
  function_name = var.rdsLambdaName
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "exports.test"

  timeout = 30

  runtime = "python3.8"

  s3_bucket = var.rdsLambdaCodeS3
  s3_key = var.rdsLambdaCode


  #source_code_hash = filebase64sha256(var.rdsLambdaCode)

  environment {
    variables = {
      foo = "bar"
    }
  }
}
