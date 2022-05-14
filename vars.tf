variable "server" {
  type = string
}

variable "client_key_data" {
  type = string
}

variable "certificate_authority_data" {
  type = string
}

variable "client_certificate_data" {
  type = string
}

variable "vault_pass" {
  type = string
}

variable "vault_username" {
  type = string
}

variable "domain" {
  type = string
}

variable "namespaces" {
  type = list(string)
}
