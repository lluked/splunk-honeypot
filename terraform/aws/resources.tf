resource "aws_vpc" "splunk-honeypot" {
  cidr_block           = var.VPC_CIDRBlock
  instance_tenancy     = var.VPC_InstanceTenancy
  enable_dns_support   = var.VPC_DNSSupport
  enable_dns_hostnames = var.VPC_DNSHostNames

  tags = {
    Name = "Splunk-Honeypot VPC"
    }
}

resource "aws_subnet" "splunk-honeypot" {
  vpc_id                  = aws_vpc.splunk-honeypot.id
  cidr_block              = var.VPC_SubnetCIDRBlock
  map_public_ip_on_launch = var.VPC_MapPublicIP

  tags = {
    Name = "Splunk-Honeypot Subnet"
  }
}

resource "aws_route_table" "splunk-honeypot" {
  vpc_id = aws_vpc.splunk-honeypot.id

  tags = {
    Name = "Splunk-Honeypot Route Table"
  }
}

resource "aws_route_table_association" "splunk-honeypot" {
  subnet_id      = aws_subnet.splunk-honeypot.id
  route_table_id = aws_route_table.splunk-honeypot.id
}

resource "aws_internet_gateway" "splunk-honeypot" {
  vpc_id = aws_vpc.splunk-honeypot.id

  tags = {
    Name = "Splunk-Honeypot Internet Gateway"
  }
}

resource "aws_route" "splunk-honeypot" {
  route_table_id         = aws_route_table.splunk-honeypot.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.splunk-honeypot.id
}

resource "aws_network_acl" "splunk-honeypot" {
  vpc_id = aws_vpc.splunk-honeypot.id
  subnet_ids = [ aws_subnet.splunk-honeypot.id ]

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "Splunk-Honeypot Network ACL"
  }
}

resource "aws_security_group" "splunk-honeypot" {
  name        = "splunk-honeypot"
  description = "splunk-honeypot Security Group"
  vpc_id      = aws_vpc.splunk-honeypot.id

  ingress {
    description = "Cowrie - SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Cowrie - Telnet"
    from_port   = 23
    to_port     = 23
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Web - HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  ingress {
    description = "Web - HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  ingress {
    description = "Admin - SSH"
    from_port   = 50220
    to_port     = 50220
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Splunk-Honeypot Security Group"
  }
}

resource "aws_key_pair" "splunk-honeypot" {
  key_name   = var.EC2_SSH_Key_Name
  public_key = tls_private_key.splunk-honeypot.public_key_openssh
}

resource "aws_instance" "splunk-honeypot" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.EC2_Instance_Type
  key_name                    = aws_key_pair.splunk-honeypot.key_name
  subnet_id                   = aws_subnet.splunk-honeypot.id
  vpc_security_group_ids      = [aws_security_group.splunk-honeypot.id]
  user_data_base64            = data.template_cloudinit_config.config.rendered
  associate_public_ip_address = true

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = true
  }

  tags = {
    Name = "splunk-honeypot"
  }
}