variable "gcp_project_id" {
  type        = string
  description = "The ID of the GCP project."
  default     = "hashicorp-demos-476611"
}

variable "public_oidc_issuer_url" {
  type        = string
  description = "HCP Terraform Cloud hostname or TFE instance URL you'd like to use as OIDC issuer."
  default = "https://app.terraform.io"

  validation {
    condition     = startswith(var.public_oidc_issuer_url, "https://")
    error_message = "The 'public_oidc_issuer_url' must start with https://, e.g. 'https://vault.foo.com'."
  }
}

variable "app_prefix" {
  type        = string
  default     = "hcp-tf-wif"
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

variable "hcp_gcp_secret_permissions" {
  type        = list(string)
  description = "The list of permissions for HCP GCP auth custom IAM role."
  default = [
    "storage.buckets.create",
    "storage.buckets.delete",
    "storage.buckets.get",
    "storage.buckets.list"
 
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