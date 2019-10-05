# Configure the AWS Provider
provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}
# Create a VPC
 resource "aws_vpc" "samdevops" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "samdevops"
  }
}
 resource "aws_subnet" "samsubmain1" {
  vpc_id     = "${aws_vpc.samdevops.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "samsubmain1"
  }
}

resource "aws_subnet" "samsubmain2" {
  vpc_id     = "${aws_vpc.samdevops.id}"
  cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1b"

  tags = {
    Name = "samsubmain2"
  }
}

 resource "aws_internet_gateway" "samdevops-route-gw" {
  vpc_id = "${aws_vpc.samdevops.id}"

  tags = {
    Name = "samdevops-gw"
  }
}

 resource "aws_route_table" "samdevops-route-table" {
  vpc_id = "${aws_vpc.samdevops.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.samdevops-route-gw.id}"
  }
   tags = {
    Name = "samdevops-route-table"
  }
}
#route-table association1
resource "aws_route_table_association" "samdevops-route-associate1" {
  subnet_id      = "${aws_subnet.samsubmain1.id}"
  route_table_id = "${aws_route_table.samdevops-route-table.id}"
}

#route-table association2
 resource "aws_route_table_association" "samdevops-route-associate2" {
  subnet_id      = "${aws_subnet.samsubmain2.id}"
  route_table_id = "${aws_route_table.samdevops-route-table.id}"
}

# Define the security group for public subnet
resource "aws_security_group" "samdevops-SG" {
  vpc_id = "${aws_vpc.samdevops.id}"
  description = "Allow incoming HTTP connections & SSH access"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Samdevops-SG"
  }
}
resource "aws_instance" "sam-ec2" {
  ami = "ami-0c322300a1dd5dc79"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.samsubmain1.id}"  
  key_name = ""
  security_groups = ["${aws_security_group.samdevops-SG.id}"]

tags = {
    Name = "sam-ec2"
  }
}

resource "aws_eip" "sam-ec2-ip" {
  instance = "${aws_instance.sam-ec2.id}"
  vpc      = true
}
