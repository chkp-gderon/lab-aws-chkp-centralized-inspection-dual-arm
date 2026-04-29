output "Deployment" {
  value = "Finalizing configuration may take up to 20 minutes after deployment is finished."
}

output "mds_instance_id" {
  value = aws_instance.mds-instance.id
}
output "mds_instance_name" {
  value = aws_instance.mds-instance.tags["Name"]
}
output "mds_instance_tags" {
  value = aws_instance.mds-instance.tags
}
output "mds_public_ipv6" {
  value = local.ipv6_enabled ? one(aws_instance.mds-instance.ipv6_addresses) : null
}