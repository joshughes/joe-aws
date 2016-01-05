resource "aws_security_group" "pub" {
  name = "${var.vpc_name}-pub"
  vpc_id = "${var.vpc_id}"
  description = "Allow all inbound traffic to public subnets"
  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      self = true
      cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "app" {
  name = "${var.vpc_name}-app"
  vpc_id = "${var.vpc_id}"
  description = "Application Security Group"

  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      self = true
      security_groups = ["${aws_security_group.pub.id}"]
  }


  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db" {
  name = "${var.vpc_name}-db"
  vpc_id = "${var.vpc_id}"
  description = "Database Security Group"

  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      self = true
      security_groups = ["${aws_security_group.app.id}","${aws_security_group.nat.id}"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "nat" {
  name = "${var.vpc_name}-nat"
  vpc_id = "${var.vpc_id}"
  description = "Nat security group"

  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}
