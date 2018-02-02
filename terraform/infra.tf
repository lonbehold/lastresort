# Add your VPC ID to default below
variable "vpc_id" {
  description = "VPC ID for usage throughout the build process"
  default = "vpc-f6917c8f"
}

provider "aws" {
  region = "us-west-2"
}

###creation of gateways
#internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = "${var.vpc_id}"

  tags = {
    Name = "default_ig"
  }
}

#elastic ip for nat gateway
resource "aws_eip" "ng" {
  vpc      = true
}

#nat gateway
resource "aws_nat_gateway" "natgw" {
    allocation_id = "${aws_eip.ng.id}"
    subnet_id = "${aws_subnet.private_subnet_a.id}"
}

###creation of route tables
#public route table
resource "aws_route_table" "public_routing_table" {
  vpc_id = "${var.vpc_id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "public_routing_table"
  }
}

#private route table
resource "aws_route_table" "private_routing_table" {
  vpc_id = "${var.vpc_id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.natgw.id}"
  }

  tags {
    Name = "private_routing_table"
  }
}

###creating 3 public and private subnets
#public subneta
resource "aws_subnet" "public_subnet_a" {
    vpc_id = "${var.vpc_id}"
    cidr_block = "172.30.1.0/24"
    availability_zone = "us-west-2a"

    tags {
        Name = "public_a"
    }
}

#public subnetb
resource "aws_subnet" "public_subnet_b" {
    vpc_id = "${var.vpc_id}"
    cidr_block = "172.30.3.0/24"
    availability_zone = "us-west-2b"

    tags {
        Name = "public_b"
    }
}

#public subnetc
resource "aws_subnet" "public_subnet_c" {
    vpc_id = "${var.vpc_id}"
    cidr_block = "172.30.5.0/24"
    availability_zone = "us-west-2c"

    tags {
        Name = "public_c"
    }
}

#private subneta
resource "aws_subnet" "private_subnet_a" {
    vpc_id = "${var.vpc_id}"
    cidr_block = "172.30.2.0/24"
    availability_zone = "us-west-2a"

    tags {
        Name = "private_a"
    }
}

#private subnetb
resource "aws_subnet" "private_subnet_b" {
    vpc_id = "${var.vpc_id}"
    cidr_block = "172.30.4.0/24"
    availability_zone = "us-west-2b"

    tags {
        Name = "private_b"
    }
}

#private subnetc
resource "aws_subnet" "private_subnet_c" {
    vpc_id = "${var.vpc_id}"
    cidr_block = "172.30.6.0/24"
    availability_zone = "us-west-2c"

    tags {
        Name = "private_c"
    }
}

###subnet associations of public and private subnets
#associate public subneta with public route table
resource "aws_route_table_association" "public_subnet_a_rt_assoc" {
    subnet_id = "${aws_subnet.public_subnet_a.id}"
    route_table_id = "${aws_route_table.public_routing_table.id}"
}

#associate public subnetb with public route table
resource "aws_route_table_association" "public_subnet_b_rt_assoc" {
    subnet_id = "${aws_subnet.public_subnet_b.id}"
    route_table_id = "${aws_route_table.public_routing_table.id}"
}

#associate public subnetc with public route table
resource "aws_route_table_association" "public_subnet_c_rt_assoc" {
    subnet_id = "${aws_subnet.public_subnet_c.id}"
    route_table_id = "${aws_route_table.public_routing_table.id}"
}

#associate private subneta with public route table
resource "aws_route_table_association" "private_subnet_a_rt_assoc" {
    subnet_id = "${aws_subnet.private_subnet_a.id}"
    route_table_id = "${aws_route_table.private_routing_table.id}"
}

#associate private subnetb with public route table
resource "aws_route_table_association" "private_subnet_b_rt_assoc" {
    subnet_id = "${aws_subnet.private_subnet_b.id}"
    route_table_id = "${aws_route_table.private_routing_table.id}"
}

#associate private subnetc with public route table
resource "aws_route_table_association" "private_subnet_c_rt_assoc" {
    subnet_id = "${aws_subnet.private_subnet_c.id}"
    route_table_id = "${aws_route_table.private_routing_table.id}"
}

###security groups
#security group to allow http access
resource "aws_security_group" "http" {
  name = "allowhttp"
  vpc_id = "${var.vpc_id}"
  description = "HTTP access"

  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

#security group to allow ssh access
resource "aws_security_group" "ssh" {
  name = "allowssh"
  vpc_id = "${var.vpc_id}"
  description = "SSH access"

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

#security group to allow http and ssh access
resource "aws_security_group" "httpssh" {
  name = "allowhttpssh"
  vpc_id = "${var.vpc_id}"
  description = "HTTP and SSH access"

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

###ec2 instances
#bastion instance
resource "aws_instance" "bastion" {
    ami = "ami-1ee65166"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.public_subnet_a.id}"
	associate_public_ip_address = true
	vpc_security_group_ids = ["${aws_security_group.ssh.id}"]
	key_name = "lastresort"
	
	tags{
		Name = "bastion"
	}
}

#1st web instance
resource "aws_instance" "web1" {
    ami = "ami-f2d3638a"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.private_subnet_a.id}"
	vpc_security_group_ids = ["${aws_security_group.httpssh.id}"]
	key_name = "lastresort"
	
	tags {
		Name = "webserver-a"
	}
}

