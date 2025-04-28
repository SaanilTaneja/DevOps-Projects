variable "ami" {
	type = string
}

variable "type" {
	type = map(string)

	default = {
		dev  = "t2.micro"
		prod = "t2.medium"
	}
}
