
output "private_db_subnets" {
  value = "${join(",", aws_subnet.private_db.*.id)}"
}

output "private_app_subnets" {
  value = "${join(",", aws_subnet.private_app.*.id)}"
}


output "public_fe_subnets" {
  value = "${join(",", aws_subnet.public_fe.*.id)}"
}

output "vpc_id" {
  value = "${aws_vpc.mod.id}"
}

output "app_sg_id" {
  value = "${module.security_groups.app_id}"
}

output "db_sg_id" {
  value = "${module.security_groups.db_id}"
}

output "pub_sg_id" {
  value = "${module.security_groups.pub_id}"
}

output "nat_sg_id" {
  value = "${module.security_groups.nat_id}"
}
