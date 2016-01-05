provider "aws" {

}

resource "aws_key_pair" "deployer" {
  key_name = "deployer-key"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}


module "vpc" {
    source = "../modules/vpc"
    name = "${var.vpc_name}"

    aws_key_name         = "${aws_key_pair.deployer.key_name}"
    aws_key_location     = "~/.ssh/id_rsa"
    networkprefix        = "10.249"
    cidr                 = "${var.vpc_cidr}"
    private_app_subnets  = "10.249.30.0/24,10.249.20.0/24,10.249.10.0/24"
    private_db_subnets   = "10.249.40.0/24,10.249.50.0/24,10.249.60.0/24"
    public_fe_subnets    = "10.249.70.0/24,10.249.80.0/24,10.249.90.0/24"
    azs                  = "${var.azs}"
}


resource "aws_launch_configuration" "launch_config" {
    image_id = "${var.ami}"
    instance_type = "t2.micro"
    key_name = "${aws_key_pair.deployer.key_name}"
    security_groups = ["${module.vpc.app_sg_id}"]
}

resource "aws_autoscaling_policy" "scale_up" {
  name = "prod-app-scale-up"
  scaling_adjustment = 50
  adjustment_type = "PercentChangeInCapacity"
  cooldown = 600
  autoscaling_group_name = "${aws_autoscaling_group.ag_conf.name}"
}

resource "aws_autoscaling_policy" "scale_down" {
  name = "prod-app-scale-down"
  scaling_adjustment = -25
  adjustment_type = "PercentChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.ag_conf.name}"
}

resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
    alarm_name = "prod-bowtie-app-scale-up"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "120"
    statistic = "Average"
    threshold = "70"
    dimensions {
        AutoScalingGroupName = "${aws_autoscaling_group.ag_conf.name}"
    }
    alarm_description = "This scale up monitor ec2 cpu utilization"
    alarm_actions = ["${aws_autoscaling_policy.scale_up.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
    alarm_name = "prod-bowtie-app-scale-down"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "120"
    statistic = "Average"
    threshold = "20"
    dimensions {
        AutoScalingGroupName = "${aws_autoscaling_group.ag_conf.name}"
    }
    alarm_description = "This scale up monitor ec2 cpu utilization"
    alarm_actions = ["${aws_autoscaling_policy.scale_down.arn}"]
}

resource "aws_elb" "prod_application_lb" {
  name = "prd-usw-pr-app-prod-application"
  security_groups = ["${module.vpc.pub_sg_id}"]
  subnets = ["${split(",", module.vpc.public_fe_subnets)}"]

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 5
    target = "HTTP:80/"
    interval = 30
  }

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

}

resource "aws_autoscaling_group" "ag_conf" {
  name = "prd-usw-pr-app-${aws_launch_configuration.launch_config.name}"
  vpc_zone_identifier = ["${split(",", module.vpc.private_app_subnets)}"]
  max_size = "6"
  min_size = "3"
  health_check_grace_period = 120
  health_check_type = "ELB"
  launch_configuration = "${aws_launch_configuration.launch_config.name}"
  vpc_zone_identifier = ["${split(",", module.vpc.private_app_subnets)}"]
  load_balancers = ["${aws_elb.prod_application_lb.name}"]
  tag{
    key = "Name"
    value = "prd-usw-pr-app-autoscaling"
    propagate_at_launch = true
  }
}
