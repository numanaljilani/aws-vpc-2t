variable "cidr_block_vpc-ap-south-1" {
  type        = string
  description = "cidr block for the vpc"
  default     = "10.0.0.0/16"
}

variable "public-subnets" {
  type        = list(string)
  description = "list of public subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private-subnets" {
  type        = list(string)
  description = "list of private subnets"
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability-zones" {
  type        = list(string)
  description = "list of availability zones"
  default     = ["ap-south-1a", "ap-south-1b"]
}

