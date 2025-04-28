provider "aws" {
	alias = "ap-south-1"
	region = "ap-south-1"
}

resource "aws_instance" "example" {
	ami = var.ami
	instance_type = var.instance_type
	subnet_id = var.subnet_id
	key_name = var.keyvalue_pair
	provider = aws.ap-south-1
}
