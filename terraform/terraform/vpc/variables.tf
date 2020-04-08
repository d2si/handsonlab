variable "region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-1"
}

variable "name" {
  type        = string
  description = "VPC name"
  default     = "test"
}

variable "cidr_block" {
  type        = string
  description = "The CIDR block for the VPC"
  default     = ""
}

variable "subnet_pub_cidr_list" {
  type        = list
  description = "list of cidr for each AZ"
  default     = []
}

variable "subnet_priv_cidr_list" {
  type        = list
  description = "list of cidr for each AZ"
  default     = []
}

variable "tags" {
  type        = map
  description = "Tags for all resources"
  default     = {}
}
