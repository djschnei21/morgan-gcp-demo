terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.45.0"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "0.109.0"
    }
    tfe = {
      source = "hashicorp/tfe"
      version = "0.68.1"
    }
    vault = {
      source = "hashicorp/vault"
      version = "5.1.0"
    }
  }
}

provider "google" {
  project     = "hc-ec2367a30f42472eb1834003fee"
  region      = "us-east1"
}

provider "hcp" {
  project_id = "f1fc24b1-4dbb-44e9-a632-dc130651e59e"
}

provider "tfe" {}

provider "vault" {
  address = "https://vault-morgan-gcp-demo-public-vault-9febeef3.91f10f5f.z1.hashicorp.cloud:8200"
  namespace = "admin"
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
resource "google_service_account" "secrets_engine" {
  account_id   = "hcp-vault-secrets-engine"
  display_name = "HCP Vault Secrets Engine"
}

# Updates the IAM policy to grant the service account permissions
# within the project.
#
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam
resource "google_project_iam_member" "secrets_engine" {
  for_each = toset([
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountKeyAdmin",
    "roles/resourcemanager.projectIamAdmin"
  ])
  project = var.gcp_project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.secrets_engine.email}"
}

# Credentials for HCP Vault to use to authenticate with GCP.
#
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account_key
resource "google_service_account_key" "secrets_engine_key" {
  service_account_id = google_service_account.secrets_engine.name
}