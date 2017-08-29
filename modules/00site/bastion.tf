resource "aws_instance" "bastion" {
  ami                             = "${var.ami}"
  availability_zone               = "${var.availability_zone}"
  instance_type                   = "t2.micro"
  subnet_id                       = "${aws_subnet.dmz_subnet_0.id}"
  vpc_security_group_ids          = ["${aws_security_group.bastion_security_group.id}"]
  source_dest_check               = false
  key_name                        = "${var.key_name}"
  associate_public_ip_address     = true


  tags {
    Name = "hello_world_${var.env}"
  }
}

resource "aws_subnet" "dmz_subnet_0" {
  vpc_id            = "${aws_vpc.personal_vpc.id}"
  availability_zone = "${var.availability_zone}"
  cidr_block        = "10.14.80.0/24"

  tags {
    Name = "dmz_subnet_0_${var.env}"
  }
}

resource "aws_route_table_association" "bastion" {
  subnet_id = "${aws_subnet.dmz_subnet_0.id}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

resource "aws_security_group" "bastion_security_group" {
  name = "bastion_security_group"
  description = "Allows all traffic"
  vpc_id = "${aws_vpc.personal_vpc.id}"

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
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

