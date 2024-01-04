

# 1) create vpc 
resource "aws_vpc" "vpc-ap-south-1" {
  cidr_block = var.cidr_block_vpc-ap-south-1
  tags = {
    Name = "vpc : vpc-ap-south-1"
  }
}

# 2) create subnets
# i) public subnet
resource "aws_subnet" "public-subnet" {
  count             = length(var.public-subnets)
  vpc_id            = aws_vpc.vpc-ap-south-1.id
  cidr_block        = element(var.public-subnets, count.index)
  availability_zone = element(var.availability-zones, count.index)
  tags = {
    Name = "public-subnet : public subnet ${count.index + 1}"
  }
}

# ii) private subnet
resource "aws_subnet" "private-subnet" {
  count             = length(var.private-subnets)
  vpc_id            = aws_vpc.vpc-ap-south-1.id
  cidr_block        = element(var.private-subnets, count.index)
  availability_zone = element(var.availability-zones, count.index)
  tags = {
    Name = "provate-subnet : private subnet ${count.index + 1}"
  }
}


# 3) create internet gatway

resource "aws_internet_gateway" "internet-gateway-ap-south-1" {
  vpc_id = aws_vpc.vpc-ap-south-1.id
  tags = {
    Name = "Intenet_Gatway : ap-south-1"
  }
}

# 4) create elastic ip for private subnets

resource "aws_eip" "nat-eip" {
  count = length(var.private-subnets)
  #   vpc = true # depricated now
}

# 5) create an nat gatway which depends on the elastic ip

resource "aws_nat_gateway" "nat-gateway" {
  count         = length(var.private-subnets)
  depends_on    = [aws_eip.nat-eip]
  allocation_id = aws_eip.nat-eip[count.index].id
  subnet_id     = aws_subnet.private-subnet[count.index].id
  tags = {
    Name = "Nat gateway : ap-south-1"
  }
}

# 6) create route table 

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc-ap-south-1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway-ap-south-1.id
  }

  tags = {
    Name = "public RT : ap-south-1"
  }
}

resource "aws_route_table" "private-route-table" {
  count = length(var.private-subnets)
  vpc_id = aws_vpc.vpc-ap-south-1.id
  depends_on = [ aws_nat_gateway.nat-gateway ]

  route = {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gateway[count.index].id
  }

  tags = {
    Name = "private RT : ap-south-1"
  }
}

# 7) route table association 
resource "aws_route_table_association" "public-route-table-association" {
  count = length(var.public-subnets)
  depends_on = [ "aws_route_table.public-route-table","aws_subnet.public-subnet" ]
  subnet_id = element(aws_subnet.public-subnet[*].id)
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_route_table_association" "private-route-table-association" {
  count = length(var.private-subnets)
  depends_on = [ "aws_route_table.private-route-table","aws_subnet.private-subnet" ]
  subnet_id = element(aws_subnet.private-subnet[*].id)
  route_table_id = aws_route_table.private-route-table.id
}