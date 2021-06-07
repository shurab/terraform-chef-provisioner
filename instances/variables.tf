variable "region" {
  description = "The region Terraform deploys your instance"
}

variable "validator_name" {
  description = "Name of validation client"
}

variable "chef_server_url" {
  description = "URL of private instance of Chef Infra server"
}

variable "validator_private_key" {
  description = "RSA Private key of validation client"
}

variable "node_name" {
  description = "The node name for this client"
}

variable "environment" {
  description = "Chef Infra Client environment on the node"
}
