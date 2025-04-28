variable "instance_type" {
        description = "EC2 Instance Type"
        type = string
}

variable "ami" {
        description = "AMI ID"
        type = string
}

variable "subnet_id" {
        description = "Subnet ID"
        type = string
}

variable "keyvalue_pair" {
        description = "Key Value Pair"
        type = string
}
