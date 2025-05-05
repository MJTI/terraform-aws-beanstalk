variable "aws-region" {
  default = "us-east-1"
}

variable "instance-count" {
  default = 1
}

variable "project" {
  default = "mjth_profile"
}

variable "vpc-name" {
  default = "mjth-vpc"
}

variable "vpc-cidr" {
  default = "172.21.0.0/16"
}

variable "subnet_configs" {
  description = "Map of subnet configurations."
  type = map(object({
    cidr_block        = string
    availability_zone = string
    is_public         = bool
  }))

  default = {
    "pub-sub-1" = {
      cidr_block        = "172.21.1.0/24"
      availability_zone = "us-east-1a"
      is_public         = true
    }
    "pub-sub-2" = {
      cidr_block        = "172.21.2.0/24"
      availability_zone = "us-east-1b"
      is_public         = true
    }
    "pub-sub-3" = {
      cidr_block        = "172.21.3.0/24"
      availability_zone = "us-east-1c"
      is_public         = true
    }
    "priv-sub-1" = {
      cidr_block        = "172.21.4.0/24"
      availability_zone = "us-east-1a"
      is_public         = false
    }
    "priv-sub-2" = {
      cidr_block        = "172.21.5.0/24"
      availability_zone = "us-east-1b"
      is_public         = false
    }
    "priv-sub-3" = {
      cidr_block        = "172.21.6.0/24"
      availability_zone = "us-east-1c"
      is_public         = false
    }
  }

}

variable "bastions-username" {
  default = "ubuntu"
}

variable "mjth-pub" {
  type = string
}

variable "database-name" {
  default = "accounts"
}

variable "mysql-user" {
  type      = string
  sensitive = true
}

variable "myip" {
  type      = string
  sensitive = true
}

variable "mysql-pass" {
  type      = string
  sensitive = true
}

variable "rabbitmq-user" {
  type      = string
  sensitive = true
}

variable "rabbitmq-pass" {
  type      = string
  sensitive = true
}