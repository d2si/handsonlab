data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

 filter {
   name   = "owner-alias"
   values = ["amazon"]
 }

 filter {
   name   = "name"
   values = ["amzn2-ami-hvm*"]
 }
}

#
data "aws_vpc" "vpc" {
  id = var.vpc_id
}

variable "vpc_id" {
  type = string
  default = ""
  description = ""
  }

resource "aws_security_group" "allow_traffic" {
  name        = "terraform-sg-webapp"
  description = "Allow inbound traffic"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    description = "SSH from public"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP from public"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_traffic"
  }
}


data "aws_subnet" "subnet_pub_a" {
  filter {
    name   = "tag:Name"
    values = ["subnet-pub-*a"] 
  }
}

resource "aws_instance" "webapp" {
  instance_type               = var.instance_type
  ami                         = data.aws_ami.amazon-linux-2.id
  key_name                    = var.keypair
  vpc_security_group_ids      = ["${aws_security_group.allow_traffic.id}"]
  subnet_id                   = data.aws_subnet.subnet_pub_a.id
  associate_public_ip_address = true
  disable_api_termination      = true

  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = 10
    volume_type           = "gp2"
    delete_on_termination = true
  }
  
  user_data = <<EOF
#!/bin/bash
yum update -y
amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
yum install -y httpd mariadb-server
systemctl start httpd
systemctl enable httpd
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;
echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php
EOF
}
