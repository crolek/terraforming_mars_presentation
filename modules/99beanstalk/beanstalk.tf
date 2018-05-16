resource "aws_iam_instance_profile" "spike" {
  name  = "ng-beanstalk-ec2-user"
  role = "${aws_iam_role.spike.name}"
}

resource "aws_iam_role" "spike" {
  name = "ng-beanstalk-ec2-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "spike_policy" {
  name = "spike_policy_with_ECR"
  role = "${aws_iam_role.spike.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "cloudwatch:PutMetricData",
        "ds:CreateComputer",
        "ds:DescribeDirectories",
        "ec2:DescribeInstanceStatus",
        "logs:*",
        "ssm:*",
        "ec2messages:*",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:DescribeImages",
        "ecr:BatchGetImage",
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

#resource "aws_iam_role" "beanstalk_service" {
#
#}

resource "aws_subnet" "spike_0" {
  vpc_id            = "${var.vpc_id}"
  availability_zone = "${var.availability_zone_0}"
  cidr_block        = "10.14.95.0/24"

  tags {
    Name = "spike_0_${var.env}"
  }
}

resource "aws_subnet" "spike_1" {
  vpc_id            = "${var.vpc_id}"
  availability_zone = "${var.availability_zone_1}"
  cidr_block        = "10.14.96.0/24"

  tags {
    Name = "spike_1_${var.env}"
  }
}

resource "aws_route_table_association" "spike_0" {
  subnet_id = "${aws_subnet.spike_0.id}"
  route_table_id = "${var.public_route_table_id}"
}

resource "aws_route_table_association" "spike_1" {
  subnet_id = "${aws_subnet.spike_1.id}"
  route_table_id = "${var.public_route_table_id}"
}

resource "aws_elastic_beanstalk_application" "spike" {
  name        = "spike"
  description = "beanstlak spike"
}

resource "aws_elastic_beanstalk_environment" "spike" {
  name                = "sherpa-spike"
  application         = "${aws_elastic_beanstalk_application.spike.name}"
  solution_stack_name = "64bit Amazon Linux 2017.03 v2.7.2 running Docker 17.03.1-ce"

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = "${var.vpc_id}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name = "Subnets"
    value = "${aws_subnet.spike_0.id}, ${aws_subnet.spike_1.id}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name = "ELBSubnets"
    value = "${aws_subnet.spike_0.id}, ${aws_subnet.spike_1.id}"
  }

  setting {
    namespace = "aws:elb:loadbalancer"
    name = "CrossZone"
    value = "true"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "InstanceType"
    value = "t2.micro"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name = "Availability Zones"
    value = "Any 2"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name = "MinSize"
    value = "2"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name = "MaxSize"
    value = "5"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "EC2KeyName"
    value = "${var.key_name}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name = "SystemType"
    value = "enhanced"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "IamInstanceProfile"
    value = "${aws_iam_instance_profile.spike.name}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name = "ServiceRole"
    value = "beanstalk_service"  #manually created for the moment
  }

  depends_on = ["aws_iam_instance_profile.spike"]
}