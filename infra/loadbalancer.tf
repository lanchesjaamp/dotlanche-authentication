
resource "aws_lb" "dotlanche_api_lb" {
  name               = "dotlanche-api-lb"
  internal           = true
  load_balancer_type = "network"
  subnets            = [aws_subnet.private_subnet.id]

  security_groups = [aws_security_group.eks_security_group.id]

  tags = {
    Name = "dotlanche-api-lb"
  }
}

resource "aws_vpc" "dotlanches_vpc" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "Dotlanches-VPC"
    Project = "Dotlanches"
  }
}

resource "aws_lb_target_group" "dotlanche_api_tg" {
  name     = "dotlanche-api-tg"
  port     = 30045
  protocol = "TCP"
  vpc_id = aws_vpc.dotlanches_vpc.id

  health_check {
    path                = "/health"
    interval            = 60
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = {
    Name = "dotlanche-api-tg"
  }
}

resource "aws_lb_listener" "dotlanche_api_listener" {
  load_balancer_arn = aws_lb.dotlanche_api_lb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dotlanche_api_tg.arn
  }
}

data "aws_instances" "dotcluster-node-instances" {
  filter {
    name   = "tag:aws:eks:cluster-name"
    values = ["dotcluster"]
  }
}

resource "aws_lb_target_group_attachment" "dotlanche_api_tg_attachment" {
  for_each         = toset(data.aws_instances.dotcluster-node-instances.ids)
  port             = 30045
  target_group_arn = aws_lb_target_group.dotlanche_api_tg.arn
  target_id        = each.value
}

