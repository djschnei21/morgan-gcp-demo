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

variable "gcp_project_id" {
  description = "The GCP project ID where the resources will be created."
  type        = string
  default     = "hc-ec2367a30f42472eb1834003fee"
  
}

variable "vault_namespace" {
  description = "The Vault namespace where the GCP secrets engine will be created."
  type        = string
  default     = "admin"
  
}

provider "google" {
  project     = var.gcp_project_id
  region      = "us-east1"
}

provider "hcp" {
  project_id = "f1fc24b1-4dbb-44e9-a632-dc130651e59e"
}

provider "tfe" {}

provider "vault" {
  address = "https://vault-morgan-gcp-demo-public-vault-9febeef3.91f10f5f.z1.hashicorp.cloud:8200"
  namespace = var.vault_namespace
}

################ GCP RESOURCES ################

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

################ END GCP RESOURCES ################

################ HCP VAULT RESOURCES ################
# Creates an GCP Secret Backend for Vault. GCP secret backends can then issue GCP OAuth token or 
# Service Account keys, once a role has been added to the backend.
#
# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/gcp_secret_backend
resource "vault_gcp_secret_backend" "gcp_secret_backend" {
  namespace = var.vault_namespace
  path      = "gcp"

  # WARNING - These values will be written in plaintext in the statefiles for this configuration. 
  # Protect the statefiles for this configuration accordingly!
  credentials = base64decode(google_service_account_key.secrets_engine_key.private_key)

  depends_on = [
    google_service_account.secrets_engine,
    google_project_iam_member.secrets_engine
  ]
}

# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/gcp_secret_roleset
resource "vault_gcp_secret_roleset" "gcp_secret_roleset" {
  backend      = vault_gcp_secret_backend.gcp_secret_backend.path
  roleset      = "project_Owner"
  secret_type  = "access_token"
  project      = var.gcp_project_id
  token_scopes = ["https://www.googleapis.com/auth/cloud-platform"]

  binding {
    resource = "//cloudresourcemanager.googleapis.com/projects/${var.gcp_project_id}"

    roles = [
      "roles/Owner",
    ]
  }

  depends_on = [
    google_service_account.secrets_engine,
    google_project_iam_member.secrets_engine
  ]
}