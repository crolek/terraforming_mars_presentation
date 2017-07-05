resource "aws_vpc" "personal_vpc" {
  cidr_block = "${var.vpc_cidr}"

  tags {
    Name = "personal_${var.env}"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = "${aws_vpc.personal_vpc.id}"

}

resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.personal_vpc.id}"
}

resource "aws_route" "internet_route" {
  route_table_id            = "${aws_route_table.public_route_table.id}"
  gateway_id                = "${aws_internet_gateway.internet_gateway.id}"
  destination_cidr_block    = "0.0.0.0/0"
}

resource "aws_subnet" "application_subnet_0" {
  vpc_id            = "${aws_vpc.personal_vpc.id}"
  availability_zone = "${var.availability_zone}"
  cidr_block        = "10.14.90.0/24"

  tags {
    Name = "application_subnet_0_${var.env}"
  }
}

resource "aws_route_table_association" "application_subnet_0" {
  subnet_id         = "${aws_subnet.application_subnet_0.id}"
  route_table_id    = "${aws_route_table.public_route_table.id}"
}

output "vpc_id" {
  value = "${aws_vpc.personal_vpc.id}"
}

output "application_subnet_0_id" {
  value = "${aws_subnet.application_subnet_0.id}"
}