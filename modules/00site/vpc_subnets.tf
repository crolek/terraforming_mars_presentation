resource "aws_vpc" "personal_vpc" {
  cidr_block = "${var.vpc_cidr}"

  tags {
    Name = "personal_${var.env}"
  }
}

resource "aws_subnet" "application_subnet_0" {
  vpc_id            = "${aws_vpc.personal_vpc.id}"
  availability_zone = "${var.availability_zone}"
  cidr_block        = "10.14.1.0/24"

  tags {
    Name = "application_subnet_0_${var.env}"
  }
}



output "vpc_id" {
  value = "${aws_vpc.personal_vpc.id}"
}

output "application_subnet_0_id" {
  value = "${aws_subnet.application_subnet_0.id}"
}