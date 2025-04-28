provider "aws" {
	region = "ap-south-1"
}

resource "aws_instance" "example" {
	instance_type = "t2.micro"	
	ami = "ami-0e35ddab05955cf57"
	subnet_id = "subnet-04cb69f4d9762dbe0"
	tags = {
		Name = "tf-instance-1"
	}
}

/*resource "aws_s3_bucket" "s3_bucket" {
	bucket = "saaniltaneja-terraform-backend"
}*/

/*resource "aws_dynamodb_table" "terraform_lock" {
	name = "terraform-lock"
	billing_mode = "PAY_PER_REQUEST"
	hash_key = "LockID"

	attribute {
		name = "LockID"
		type = "S"
	}
}*/
