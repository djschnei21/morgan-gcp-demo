terraform { 
  cloud { 
    
    organization = "djs-tfcb" 

    workspaces { 
      name = "vault-backed-gcp-auth" 
    } 
  } 
}

provider "google" {}

data "google_service_accounts" "example" {
  project = "hc-ec2367a30f42472eb1834003fee"
}

resource "null_resource" "sleep" {
  provisioner "local-exec" {
    command = "sleep 30"
  }
}

output "sa_names" {
  value = data.google_service_accounts.example.accounts
}