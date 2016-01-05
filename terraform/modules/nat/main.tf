module "ami" {
  source = "github.com/terraform-community-modules/tf_aws_ubuntu_ami/ebs"
  instance_type = "${var.instance_type}"
  region = "${var.region}"
  distribution = "vivid"
}

resource "aws_instance" "nat" {
    count = "${var.instance_count}"
    ami = "${module.ami.ami_id}"
    instance_type = "${var.instance_type}"
    source_dest_check = false
    iam_instance_profile = "${aws_iam_instance_profile.nat_profile.id}"
    key_name = "${var.aws_key_name}"
    subnet_id = "${element(split(\",\", var.subnet_ids), count.index)}"
    security_groups = ["${split(\",\", var.security_groups)}"]
    tags {
        Name = "NAT ${element(split(\",\", var.az_list), count.index)}${count.index+1}"
    }
    user_data = "${replace(replace(file("${path.module}/nat.conf"), "__NETWORKPREFIX__", "${var.networkprefix}"), "__MYVPC__", "${var.vpc_id}")}"
}
