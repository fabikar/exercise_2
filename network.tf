### VPC ###

resource "aws_vpc" "inpost-prod" {
  cidr_block           = var.vpc-prod["cidr"]
  enable_dns_hostnames = var.vpc-prod["enable_dns_hostnames"]
  enable_dns_support   = var.vpc-prod["enable_dns_support"]

  tags = {
    Name = var.vpc-prod["name"]
  }
}


### DHCP OPTIONS ###

resource "aws_vpc_dhcp_options" "inpost-prod" {
  domain_name_servers = var.vpc-prod["domain_name_servers"]
  ntp_servers         = var.vpc-prod["ntp_servers"]

  tags = {
    Name = var.vpc-prod["name"]
  }
}

resource "aws_vpc_dhcp_options_association" "inpost-prod" {
  vpc_id          = aws_vpc.inpost-prod.id
  dhcp_options_id = aws_vpc_dhcp_options.inpost-prod.id
}


### SUBNETS DMZ ###

resource "aws_subnet" "prod-dmz-1a" {
  vpc_id            = aws_vpc.inpost-prod.id
  cidr_block        = var.subnet-prod-dmz-1a["cidr"]
  availability_zone = var.subnet-prod-dmz-1a["availability_zone"]

  tags = {
    Name = var.subnet-prod-dmz-1a["name"]
  }
}

resource "aws_subnet" "prod-dmz-1b" {
  vpc_id            = aws_vpc.inpost-prod.id
  cidr_block        = var.subnet-prod-dmz-1b["cidr"]
  availability_zone = var.subnet-prod-dmz-1b["availability_zone"]

  tags = {
    Name = var.subnet-prod-dmz-1b["name"]
  }
}


### SUBNETS PRV ###

resource "aws_subnet" "prod-prv-1a" {
  vpc_id            = aws_vpc.inpost-prod.id
  cidr_block        = var.subnet-prod-prv-1a["cidr"]
  availability_zone = var.subnet-prod-prv-1a["availability_zone"]

  tags = {
    Name = var.subnet-prod-prv-1a["name"]
  }
}

resource "aws_subnet" "prod-prv-1b" {
  vpc_id            = aws_vpc.inpost-prod.id
  cidr_block        = var.subnet-prod-prv-1b["cidr"]
  availability_zone = var.subnet-prod-prv-1b["availability_zone"]

  tags = {
    Name = var.subnet-prod-prv-1b["name"]
  }
}


### INTERNET GATEWAY ###

resource "aws_internet_gateway" "inpost-prod" {
  vpc_id = aws_vpc.inpost-prod.id

  tags = {
    Name = var.vpc-prod["name"]
  }
}


### ROUTE TABLES DMZ ###

### PROD DMZ 1a
resource "aws_route_table" "prod-dmz-1a" {
  vpc_id = aws_vpc.inpost-prod.id

  tags = {
    Name = "PROD DMZ 1a"
  }
}

resource "aws_route" "prod-dmz-1a-01" {
  route_table_id         = aws_route_table.prod-dmz-1a.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.inpost-prod.id
  depends_on             = [aws_route_table.prod-dmz-1a]
}

resource "aws_route_table_association" "prod-dmz-1a" {
  subnet_id      = aws_subnet.prod-dmz-1a.id
  route_table_id = aws_route_table.prod-dmz-1a.id
}

### PROD DMZ 1b
resource "aws_route_table" "prod-dmz-1b" {
  vpc_id = aws_vpc.inpost-prod.id

  tags = {
    Name = "PROD DMZ 1b"
  }
}

resource "aws_route" "prod-dmz-1b-01" {
  route_table_id         = aws_route_table.prod-dmz-1b.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.inpost-prod.id
  depends_on             = [aws_route_table.prod-dmz-1b]
}

resource "aws_route_table_association" "prod-dmz-1b" {
  subnet_id      = aws_subnet.prod-dmz-1b.id
  route_table_id = aws_route_table.prod-dmz-1b.id
}


### PROD PRV 1a
resource "aws_route_table" "prod-prv-1a" {
  vpc_id = aws_vpc.inpost-prod.id

  tags = {
    Name = "PROD PRV 1a"
  }
}

resource "aws_route_table_association" "prod-prv-1a" {
  subnet_id      = aws_subnet.prod-prv-1a.id
  route_table_id = aws_route_table.prod-prv-1a.id
}

### PROD PRV 1b
resource "aws_route_table" "prod-prv-1b" {
  vpc_id = aws_vpc.inpost-prod.id

  tags = {
    Name = "PROD PRV 1b"
  }
}

resource "aws_route_table_association" "prod-prv-1b" {
  subnet_id      = aws_subnet.prod-prv-1b.id
  route_table_id = aws_route_table.prod-prv-1b.id
}
