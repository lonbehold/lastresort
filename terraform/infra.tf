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
    subnet_id = "${aws_subnet.public_subnet_a.id}"
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

#security group to allow http and ssh access for web instances
resource "aws_security_group" "httpssh" {
  name = "allowhttpssh"
  vpc_id = "${var.vpc_id}"
  description = "HTTP and SSH access"

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["172.30.0.0/16"]
  }
  
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
  
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

#security group for access to DB
resource "aws_security_group" "db" {
  name = "sgfordb"
  vpc_id = "${var.vpc_id}"
  description = "DB access from VPC network only"  

  ingress {
      from_port = 3306
      to_port = 3306
      protocol = "tcp"
      cidr_blocks = ["172.30.0.0/16"]
  }
  
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

#sg for elb
/*resource "aws_security_group" "sgforlb" {
  name        = "lb-security-group"
  vpc_id      = "${var.vpc_id}"
  description = "Allow web incoming traffic to load balancer"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}*/

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

#web instance A
resource "aws_instance" "weba" {
    ami = "ami-7f43f307"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.private_subnet_a.id}"
	associate_public_ip_address = false
	private_ip = "172.30.2.167"
	vpc_security_group_ids = ["${aws_security_group.httpssh.id}"]
	key_name = "lastresort"
	
	tags {
		Name = "webserver-a"
	}
}

#web instance b
/*resource "aws_instance" "webb" {
    ami = "ami-7f43f307"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.private_subnet_b.id}"
	associate_public_ip_address = false
	vpc_security_group_ids = ["${aws_security_group.httpssh.id}"]
	key_name = "lastresort"
	
	tags {
		Name = "webserver-b"
	}
}*/

#db subnet group to reference private_b and private_c
resource "aws_db_subnet_group" "subgroupbc" {
    name = "main"
    subnet_ids = ["${aws_subnet.private_subnet_b.id}", "${aws_subnet.private_subnet_c.id}"]
    
	tags {
        Name = "My DB subnet group"
    }
}

#rds instance
resource "aws_db_instance" "mysqldb" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "5.6.37"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  identifier           = "sqldbforweb"
  username             = "foo"
  password             = "barbarbar"
  db_subnet_group_name = "${aws_db_subnet_group.subgroupbc.id}"
  vpc_security_group_ids = ["${aws_security_group.db.id}"]
  multi_az = false
  #final_snapshot_identifier = "test"
  copy_tags_to_snapshot = false
  skip_final_snapshot = true
  
  tags{
	Name = "dbforweb"
  }
}

#Load balancer for web instances
/*resource "aws_elb" "lbforweb" {
  name = "elb"
  subnets = ["${aws_subnet.public_subnet_b.id}", "${aws_subnet.public_subnet_c.id}"]

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
  
  listener {
    instance_port = 443
    instance_protocol = "http"
    lb_port = 443
    lb_protocol = "https"
	ssl_certificate_id = "lastresort"
  }

  health_check {
    healthy_threshold = 10
    unhealthy_threshold = 2
    timeout = 2
    target = "HTTP:80/"
    interval = 10
  }

  instances = ["${aws_instance.weba.id}", "${aws_instance.webb.id}"]
  connection_draining = true
  connection_draining_timeout = 300
  security_groups = ["${aws_security_group.sgforlb.id}"]

  tags {
    Name = "myelb"
  }
}*/