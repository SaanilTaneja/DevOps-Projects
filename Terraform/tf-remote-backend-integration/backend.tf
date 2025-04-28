terraform {
	backend "s3" {
		bucket = "saaniltaneja-terraform-backend"
		key    = "terraform/terraform.tfstate"
		region = "ap-south-1"
		use_lockfile = true
	}
}
