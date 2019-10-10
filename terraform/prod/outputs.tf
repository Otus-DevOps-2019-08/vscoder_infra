output "app_external_ip" {
  value = module.app.app_external_ip
}
output "app_url" {
  value = "http://${module.app.app_external_ip}:9292"
}
output "db_internal_ip" {
  value = module.db.db_internal_ip
}
output "database_url" {
  value = "${module.db.db_internal_ip}:27017"
}
