provider "aws" {
	region = "ap-south-1"
}

module "ec2_instance" {
	source        = "/home/saaniltaneja/Projects/Terraform/tf-simple-ec2-create/modules/ec2_instance/"
	instance_type = "t2.micro"
	ami           = "ami-0e35ddab05955cf57"
	subnet_id     = "subnet-04cb69f4d9762dbe0"
	keyvalue_pair = "keypair"
}
