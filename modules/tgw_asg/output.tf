output "management_instance_name" {
  value = try(module.management[0].management_instance_name, null)
}
output "configuration_template" {
  value = var.configuration_template
}
output "controller_name" {
  value = "tgw-controller"
}
output "management_public_ip" {
  value = try(module.management[0].management_public_ip, null)
}
output "management_public_ipv6" {
  value = try(module.management[0].management_public_ipv6, null)
}
output "management_url" {
  value = try(module.management[0].management_url, null)
}
output "management_url_ipv6" {
  value = try(module.management[0].management_url_ipv6, null)
}
output "autoscaling_group_name" {
  value = module.autoscale.autoscale_autoscaling_group_name
}
