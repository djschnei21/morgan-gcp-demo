variable "gcp_project_id" {
  type        = string
  description = "The ID of the GCP project."
  default     = "hashicorp-demos-476611"
}

variable "public_oidc_issuer_url" {
  type        = string
  description = "Publicly available URL of Vault or an external proxy that serves the OIDC discovery document."
  default = "https://vault-cluster-public-vault-bc651c7f.99c89f97.z1.hashicorp.cloud:8200"

  validation {
    condition     = startswith(var.public_oidc_issuer_url, "https://")
    error_message = "The 'public_oidc_issuer_url' must start with https://, e.g. 'https://vault.foo.com'."
  }
}

variable "app_prefix" {
  type        = string
  description = "The prefix for the Vault plugin app"
  default     = "vault-plugin-wif"
}

variable "activate_apis" {
  description = "The list of apis to activate within the project"
  type        = list(string)
  default = [
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "sts.googleapis.com",
    "iamcredentials.googleapis.com",
    "compute.googleapis.com"
  ]
}

variable "vault_gcp_secret_permissions" {
  type        = list(string)
  description = "The list of permissions for Vault GCP auth custom IAM role."
  default = [
    # Service account + key admin
    "iam.serviceAccounts.create",
    "iam.serviceAccounts.delete",
    "iam.serviceAccounts.get",
    "iam.serviceAccounts.list",
    "iam.serviceAccounts.update",
    "iam.serviceAccountKeys.create",
    "iam.serviceAccountKeys.delete",
    "iam.serviceAccountKeys.get",
    "iam.serviceAccountKeys.list",

    # For `access_token` secrets and impersonated accounts
    "iam.serviceAccounts.getAccessToken",

    # For `service_account_keys` secrets
    "iam.serviceAccountKeys.create",
    "iam.serviceAccountKeys.delete",
    "iam.serviceAccountKeys.get",
    "iam.serviceAccountKeys.list",

    # When using rolesets or static accounts with bindings, Vault must have permissions on those resources.
    # Projects
    "resourcemanager.projects.getIamPolicy",
    "resourcemanager.projects.setIamPolicy",

    # # All compute
    # "compute.*.getIamPolicy",
    # "compute.*.setIamPolicy",

  ]
}


variable "tfc_hostname" {
  type        = string
  default     = "app.terraform.io"
  description = "The hostname of the TFC or TFE instance you'd like to use with Vault"
}

variable "tfc_organization_name" {
  type        = string
  default     = "djs-tfcb"
  description = "The name of your Terraform Cloud organization"
}

variable "tfc_project_name" {
  type        = string
  default     = "morgan-gcp-demo"
  description = "The project under which a workspace will be created"
}

# Variables for Vault

variable "jwt_backend_path" {
  type        = string
  default     = "jwt"
  description = "The path at which you'd like to mount the jwt auth backend in Vault"
}

variable "tfc_vault_audience" {
  type        = string
  default     = "vault.workload.identity"
  description = "The audience value to use in run identity tokens"
}