variable "ubuntu_ami" {
  default = "ami-0b6d9d3d33ba97d99"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type    = string
  default = "pep-project"
}