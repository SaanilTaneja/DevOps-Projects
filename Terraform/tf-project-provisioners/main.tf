provider "aws" {
	region = "ap-south-1"
}

variable "cidr" {
	default = "10.0.0.0/16"
}

resource "aws_key_pair" "key_pair" {
	key_name = "keypair2"
	public_key = file("/home/saaniltaneja/.ssh/id_rsa.pub")
}

resource "aws_vpc" "new_vpc" {
	cidr_block = var.cidr
}

resource "aws_subnet" "subnet_1" {
	vpc_id                  = aws_vpc.new_vpc.id 
	cidr_block              = "10.0.0.0/24"
	availability_zone       = "ap-south-1a"
	map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "internet_gw" {
	vpc_id = aws_vpc.new_vpc.id
}

resource "aws_route_table" "route_table" {
	vpc_id = aws_vpc.new_vpc.id
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.internet_gw.id
	}
}

resource "aws_route_table_association" "rta1" {
	subnet_id      = aws_subnet.subnet_1.id 
	route_table_id = aws_route_table.route_table.id
}

resource "aws_security_group" "tf_sg" {
	name   = "web"
	vpc_id = aws_vpc.new_vpc.id

	ingress {
		description  = "HTTP Allow"
		from_port    = 80
		to_port      = 80
		protocol     = "tcp"
		cidr_blocks  = ["0.0.0.0/0"]
	}
        ingress {
                description  = "HTTPS Allow"
                from_port    = 443
                to_port      = 443
                protocol     = "tcp"
                cidr_blocks  = ["0.0.0.0/0"]
	}
        ingress {
                description  = "SSH Allow"
                from_port    = 22
                to_port      = 22
                protocol     = "tcp"
                cidr_blocks  = ["0.0.0.0/0"]
	}

        egress {
                from_port    = 0
                to_port      = 0
                protocol     = "-1"
                cidr_blocks  = ["0.0.0.0/0"]
	}

	tags = {
		Name = "tf_app_sg"
	}
}

resource "aws_instance" "server" {
	ami                    = "ami-0e35ddab05955cf57"
	instance_type          = "t2.micro"
	key_name               = aws_key_pair.key_pair.key_name
	vpc_security_group_ids = [aws_security_group.tf_sg.id]
	subnet_id              = aws_subnet.subnet_1.id

		connection {
			type        = "ssh"
			user        = "ubuntu"
			private_key = file("/home/saaniltaneja/.ssh/id_rsa") 
			host        = self.public_ip
		}

		provisioner "file" {
			source      = "/home/saaniltaneja/Projects/Terraform/tf-provisioner-project/app.py"
			destination = "/home/ubuntu/app.py" 
		}

		provisioner "remote-exec" {
			inline = [
				"Hello 'Configuring remote instance'",
				"sudo apt update -y",
				"sudo apt install -y python3-pip",
				"cd /home/ubuntu",
				"sudo pip3 install flask",
				"sudo nohup python3 app.py &",
			]
		}
}
