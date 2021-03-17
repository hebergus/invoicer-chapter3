output "cname" {
  value = module.invoicer_db.cname
}

output "env_name" {
  value = module.invoicer_db.env_name
}

output "env_id" {
  value = module.invoicer_db.env_id
}

output "app_version" {
  value = module.invoicer_db.app_version
}

output "deployer_cname" {
  value = module.deployer.cname
}

output "deployer_env_name" {
  value = module.deployer.env_name
}

output "deployer_env_id" {
  value = module.deployer.env_id
}

output "deployer_app_version" {
  value = module.deployer.app_version
}
