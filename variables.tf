variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "EC2 instance type."
}

variable "aws_region" {
  type        = string
  default     = "eu-west-1"
  description = "AWS region to deploy resources."
}

variable "instance_count" {
  type        = number
  default     = 2
  description = "Number of Kubernetes nodes."
}

variable "vpc_cidr_block" {
  type        = string
  default     = "172.16.0.0/16"
  description = "CIDR block for the VPC."
}

variable "public_subnet_cidr" {
  type        = string
  default     = "172.16.10.0/24"
  description = "CIDR block for the public subnet."
}

variable "my_ip" {
  type        = string
  description = "Your public IP in CIDR notation for SSH access (e.g. 1.2.3.4/32)."
  default     = "0.0.0.0/0"
}

variable "instance_password" {
  type        = string
  sensitive   = true
  description = "SSH password for ubuntu user."
}

variable "public_ssh_key" {
  type        = string
  description = "SSH public KEY full path."
}