data "aws_subnets" "private_subnets" {
  filter {
    name   = "tag:Project"
    values = ["Dotlanches"]
  }

  filter {
    name   = "tag:type"
    values = ["private"]
  }
}

resource "aws_security_group" "eks_security_group" {
  name        = "eks-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = aws_vpc.dotlanches_vpc.id  # ID da VPC onde o SG será criado

  # Regras de entrada (inbound)
  ingress {
    description = "Allow inbound traffic from specific CIDR"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow inbound traffic from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # Substitua pelo CIDR da sua VPC
  }

  # Regras de saída (outbound)
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                = "eks-cluster-sg"
    "aws:eks:cluster-name" = "dotcluster"  # Tag associando o SG ao cluster EKS
  }
}


resource "aws_apigatewayv2_api" "apigateway" {
  name          = "dotlanches-api-gateway"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "apigateway-stage" {
  api_id = aws_apigatewayv2_api.apigateway.id

  name        = "$default"
  auto_deploy = true
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.dotlanches_vpc.id  # Referencie a VPC que você criou
  cidr_block        = "10.0.1.0/24"  # Subnet CIDR Block
  availability_zone = "us-east-1a"  # Escolha uma zona de disponibilidade da região

  tags = {
    Name    = "Dotlanches-Private-Subnet"
    Project = "Dotlanches"
  }
}


resource "aws_apigatewayv2_vpc_link" "apigateway-vpc_link" {
  name               = "EKS_LB"
  security_group_ids = [aws_security_group.eks_security_group.id]
    subnet_ids       = [aws_subnet.private_subnet.id]
}

output "api_gateway_url" {
  description = "Base URL for API Gateway"

  value = aws_apigatewayv2_stage.apigateway-stage.invoke_url
}
