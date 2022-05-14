provider "kubernetes" {
  host = var.server

  client_certificate     = base64decode(var.client_certificate_data)
  client_key             = base64decode(var.client_key_data)
  cluster_ca_certificate = base64decode(var.certificate_authority_data)
}


provider "helm" {
  kubernetes {
    host = var.server

    client_certificate     = base64decode(var.client_certificate_data)
    client_key             = base64decode(var.client_key_data)
    cluster_ca_certificate = base64decode(var.certificate_authority_data)
  }
}

provider "vault" {
  address = "http://localhost"
  auth_login {
    path = "auth/userpass/login/${var.vault_username}"
    parameters = {
      password = var.vault_pass
    }
  }
}
