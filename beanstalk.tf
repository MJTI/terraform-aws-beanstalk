resource "aws_elastic_beanstalk_application" "mjth-application" {
  name        = "mjth-app"
  description = "mjth-tomcat-application"

  tags = {
    Name       = "mjth-tomcat-application"
    Managed_By = "Terraform"
    Project    = var.project
  }
}

resource "aws_elastic_beanstalk_environment" "mjth-environment" {
  name                = "mjth-app"
  application         = aws_elastic_beanstalk_application.mjth-application.name
  solution_stack_name = "64bit Amazon Linux 2023 v5.6.1 running Tomcat 11 Corretto 21"
  cname_prefix        = "mjth-app"

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_vpc.mjth-vpc.id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", [for s in aws_subnet.private-subnets : s.id])
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", [for s in aws_subnet.public-subnets : s.id])
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
  }

  setting {
    namespace = "aws:elbv2:loadbalancer"
    name      = "SecurityGroups"
    value     = aws_security_group.ALB-beanstalk-sg.id
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = aws_key_pair.deploy-key.key_name
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "aws-elasticbeanstalk-ec2-role"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = aws_security_group.beanstalk-tomcat.id
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "DisableDefaultEC2SecurityGroup"
    value     = true
  }

  tags = {
    Name       = "mjth-tomcat-environment"
    Managed_By = "Terraform"
    Project    = var.project
  }

}