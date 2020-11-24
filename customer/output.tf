output "RDSInstanceName" {
  value = module.customerRDS.RDSInstance
}

output "LamdbaDBSetup" {
  value = module.customerRDS.lambdaDBSetup.id
}

output "LamdbaDBAPI" {
  value = module.customerRDS.lambdaDBAPI.id
}

output "apiurl" {
  value = "${module.customerRDS.apiUrl}${module.customerRDS.apiResource}"
}


output "db_admin_user"{
  value = module.customerRDS.dbAdminUser
}

output "xxxx" {
  value = module.customerRDS.xxxx
}