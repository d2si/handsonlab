variable "region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-1"
}

variable "keypair" {
    type        = string
    default     = "keypair"
    description = "KeyPair name"
}

variable "instance_type" {
    type        = string
    default     = "t2.micro"
    description = ""
}

/*
variable "" {
    type        = string
    default     = ""
    description = ""
}

variable "" {
    type        = string
    default     = ""
    description = ""
}

variable "" {
    type        = string
    default     = ""
    description = ""
}
*/
