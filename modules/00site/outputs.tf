output "vpc_id" {
  value = "${aws_vpc.personal_vpc.id}"
}

output "public_route_table_id" {
  value = "${aws_route_table.public_route_table.id}"
}

output "application_subnet_0_id" {
  value = "${aws_subnet.application_subnet_0.id}"
}

output "application_subnet_1_id" {
  value = "${aws_subnet.application_subnet_1.id}"
}

output "dmz_subnet_0_id" {
  value = "${aws_subnet.dmz_subnet_0.id}"
}

output "dmz_subnet_1_id" {
  value = "${aws_subnet.dmz_subnet_1.id}"
}