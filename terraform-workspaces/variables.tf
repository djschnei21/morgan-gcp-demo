// Input variables required by `main.tf` in this directory.

variable "tfc_project_name" {
  description = "Name of the Terraform Cloud project where the workspace will be created."
  type        = string
  default = "morgan-gcp-demo"
}

variable "tfc_organization_name" {
  description = "Name of the Terraform Cloud organization that owns the workspace."
  type        = string
  default     = "djs-tfcb"
}

variable "vault_url" {
  description = "Address (URL) of the Vault instance that runs will access (e.g., https://vault.example.com:8200)."
  type        = string
  default     = "https://vault-cluster-public-vault-bc651c7f.99c89f97.z1.hashicorp.cloud:8200"
}

variable "vault_namespace" {
  description = "Vault namespace that contains the GCP Secrets Engine. Use an empty string for the root namespace."
  type        = string
  default     = "admin/gcp_wif/"
}

variable "tfc_vault_plan_role" {
  description = "Vault role that plan will use to authenticate."
  type        = string
  default     = "tfc-role-plan"
}

variable "tfc_vault_apply_role" {
  description = "Vault role that apply will use to authenticate."
  type        = string
  default     = "tfc-role-apply"
}

variable "tfc_gcp_plan_vault_roleset" {
  description = "Id of the GCP roleset that plan will assume."
  type        = string
  default     = "project_viewer_token"
}

variable "tfc_gcp_apply_vault_roleset" {
  description = "Id of the GCP roleset that apply will assume."
  type        = string
  default     = "project_owner_token"
}