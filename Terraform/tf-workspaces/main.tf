provider "aws" {
        region = "ap-south-1"
}

module "ec2_instance" {
        source = "/home/saaniltaneja/Projects/Terraform/tf-workspaces/modules/ec2"
        type   = lookup(var.type, terraform.workspace, "t2.micro")
        ami    = var.ami
}
