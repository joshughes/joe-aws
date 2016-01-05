output "app_id" {
  value = "${aws_security_group.app.id}"
}

output "db_id" {
  value = "${aws_security_group.db.id}"
}

output "pub_id" {
  value = "${aws_security_group.pub.id}"
}

output "nat_id" {
  value = "${aws_security_group.nat.id}"
}
