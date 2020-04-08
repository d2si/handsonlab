output "ec2_instance_webapp" {
  value = "${aws_instance.webapp.public_ip}"
}