
output "RDSInstance" {
  description = "DB Instance object"
  value = aws_db_instance.RDSInstance.name
}


output "dbAdminUser" {
  value = aws_secretsmanager_secret.AdminPwdSecret.name
}


output "xxxx" {
  value = random_password.password
}

output "lambdaDBSetup" {
  description = "DB Setup lambda object"
  value = aws_lambda_function.rds_DBSetup
}

output "lambdaDBAPI" {
  description = "DB API lambda object"
  value = aws_lambda_function.rds_DBAPI
}

output "apiUrl" {
  description = "URL to access the RDSAPI"
  value = aws_api_gateway_deployment.RDSAPI.invoke_url
}

output "apiResource" {
  description = "API resource"
  value = aws_api_gateway_resource.RDSAPI.path
}


