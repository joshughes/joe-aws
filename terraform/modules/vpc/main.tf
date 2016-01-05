resource "aws_vpc" "mod" {
  cidr_block = "${var.cidr}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support = "${var.enable_dns_support}"
  tags { Name = "${var.name}" }
}

module "security_groups" {
    source = "../security_groups"
    vpc_name = "${var.name}"
    vpc_cidr = "${var.cidr}"
    vpc_id   = "${aws_vpc.mod.id}"
}

resource "aws_internet_gateway" "mod" {
  vpc_id = "${aws_vpc.mod.id}"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.mod.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.mod.id}"
  }
  tags {
    Name  = "${var.name}-public"
    vpc   = "${aws_vpc.mod.id}"
    type  = "public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.mod.id}"
  tags {
    Name  = "${var.name}-private"
    vpc   = "${aws_vpc.mod.id}"
    type  = "private"
  }
}

resource "aws_subnet" "private_app" {
  vpc_id = "${aws_vpc.mod.id}"
  cidr_block = "${element(split(",", var.private_app_subnets), count.index)}"
  availability_zone = "${element(split(",", var.azs), count.index % length(compact(split(",", var.azs))))}"
  count = "${length(compact(split(",", var.private_app_subnets)))}"
  tags { Name = "${var.name}-${replace(replace(element(split(",", var.azs), count.index % 3),"east","e"),"-","")}-pr-${format("%02d",(count.index/3 + 1 ))}-app" }
}

resource "aws_subnet" "private_db" {
  vpc_id = "${aws_vpc.mod.id}"
  cidr_block = "${element(split(",", var.private_db_subnets), count.index)}"
  availability_zone = "${element(split(",", var.azs), count.index % length(compact(split(",", var.azs))))}"
  count = "${length(compact(split(",", var.private_db_subnets)))}"
  tags { Name = "${var.name}-${replace(replace(element(split(",", var.azs), count.index % 3),"east","e"),"-","")}-pr-${format("%02d",(count.index/3 + 1 ))}-db" }
}

resource "aws_subnet" "public_fe" {
  vpc_id = "${aws_vpc.mod.id}"
  cidr_block = "${element(split(",", var.public_fe_subnets), count.index)}"
  availability_zone = "${element(split(",", var.azs), count.index % length(compact(split(",", var.azs))))}"
  count = "${length(compact(split(",", var.public_fe_subnets)))}"
  tags { Name = "${var.name}-${replace(replace(element(split(",", var.azs), count.index % 3),"east","e"),"-","")}-pu-${format("%02d",(count.index/3 + 1 ))}-fe" }

  map_public_ip_on_launch = true
}

resource "aws_route_table_association" "private_app" {
  count = "${length(compact(split(",", var.private_app_subnets)))}"
  subnet_id = "${element(aws_subnet.private_app.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "private_db" {
  count = "${length(compact(split(",", var.private_db_subnets)))}"
  subnet_id = "${element(aws_subnet.private_db.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}


resource "aws_route_table_association" "public_fe" {
  count = "${length(compact(split(",", var.public_fe_subnets)))}"
  subnet_id = "${element(aws_subnet.public_fe.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

module "nat_instances" {
  source = "../nat"
  instance_type = "t2.medium"
  region = "us-east-1"
  instance_count = "1"
  aws_key_name = "${var.aws_key_name}"
  subnet_ids = "${join(",",aws_subnet.public_fe.*.id)}"
  security_groups = "${module.security_groups.nat_id}"
  az_list = "${var.azs}"
  networkprefix = "${var.networkprefix}"
  vpc_id = "${aws_vpc.mod.id}"
  aws_key_name = "${var.aws_key_name}"
  aws_key_location = "${var.aws_key_location}"
}
