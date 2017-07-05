resource "aws_security_group" "base_traffic_security_group" {
  name        = "base_traffic"
  description = "Allow basic access"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "hello_world_base_traffic_${var.env}"
  }
}

resource "aws_security_group" "hello_world_security_group" {
  name        = "hello_world_application"
  description = "Allow basic access"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port = 8090
    to_port = 8090
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "hello_world_application_security_group_${var.env}"
  }
}

data "template_file" "helloworld_bootstrap" {
  template = <<EOF
#!/bin/bash
apt-get update -y
apt-get install wget

mkdir -p /opt/app
cd /opt/app
wget https://s3.amazonaws.com/crolek-public/hello_world/hello_world_linux_amd64
chmod +x hello_world_linux_amd64
./hello_world_linux_amd64 &

EOF

  vars {

  }
}

resource "aws_instance" "hello_world" {
  ami                             = "${var.ami}"
  availability_zone               = "${var.availability_zone}"
  instance_type                   = "t2.micro"
  subnet_id                       = "${var.application_subnet_0_id}"
  vpc_security_group_ids          = ["${aws_security_group.base_traffic_security_group.id}", "${aws_security_group.hello_world_security_group.id}"]
  source_dest_check               = false
  key_name                        = "${var.key_name}"
  user_data                       = "${data.template_file.helloworld_bootstrap.rendered}"
  associate_public_ip_address     = true

  ebs_block_device {
    device_name = "/dev/xvde"
    volume_type = "gp2"
    volume_size = 20
  }

  tags {
    Name = "hello_world_${var.env}"
  }
}

resource "aws_route53_record" "hello_world" {
  zone_id   = "Z2F92KUB7IINUX"  # clinker.io
  name      = "hello_world"
  type      = "A"
  ttl       = "300"
  records   = ["${aws_instance.hello_world.public_ip}"]
}