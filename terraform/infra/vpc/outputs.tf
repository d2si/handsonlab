output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnet_pub_ids" {
  value = aws_subnet.public.*.id
}

output "subnet_priv_ids" {
  value = aws_subnet.private.*.id
}

output "subnet_public_cidr_block" {
  value = aws_subnet.public.*.cidr_block
}

output "subnet_private_cidr_block" {
  value  = aws_subnet.private.*.cidr_block
}
