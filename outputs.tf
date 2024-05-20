/*output "rendered_container_definitions" {
  value = data.template_file.wordpress_task.rendered
}*/

output "elb_dns" {
  value = aws_elb.ec2.dns_name
}

output "api_gateway_url" {
  value = "${aws_api_gateway_stage.redeploy_stage.invoke_url}/redeploy"
}