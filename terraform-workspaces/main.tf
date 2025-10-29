provider "tfe" {}

data "tfe_project" "tfc_project" {
  name         = var.tfc_project_name
  organization = var.tfc_organization_name
}

### VAULT BACKED WORKSPACE ###
resource "tfe_workspace" "vault_backed" {
  name         = "vault-backed"
  organization = var.tfc_organization_name
  project_id   = data.tfe_project.tfc_project.id
  working_directory = "terraform-workspaces/vault-backed"
  queue_all_runs = false
  vcs_repo {
    branch             = "main"
    identifier         = "djschnei21/morgan-gcp-demo"
    oauth_token_id     = "ot-95PZayu7N11cQW7H"
  }
}

### VAULT BACKED WORKSPACE VARIABLES ###
resource "tfe_variable" "enable_vault_provider_auth" {
  workspace_id = tfe_workspace.vault_backed.id

  key      = "TFC_VAULT_PROVIDER_AUTH"
  value    = "true"
  category = "env"

  description = "Enable the Workload Identity integration for Vault."
}

resource "tfe_variable" "tfc_vault_addr" {
  workspace_id = tfe_workspace.vault_backed.id

  key       = "TFC_VAULT_ADDR"
  value     = var.vault_url
  category  = "env"
  sensitive = true

  description = "The address of the Vault instance runs will access."
}

resource "tfe_variable" "tfc_vault_plan_role" {
  workspace_id = tfe_workspace.vault_backed.id

  key      = "TFC_VAULT_PLAN_ROLE"
  value    = var.tfc_vault_plan_role
  category = "env"

  description = "The Vault role plan will use to authenticate."
}

resource "tfe_variable" "tfc_vault_apply_role" {
  workspace_id = tfe_workspace.vault_backed.id

  key      = "TFC_VAULT_APPLY_ROLE"
  value    = var.tfc_vault_apply_role
  category = "env"

  description = "The Vault role apply will use to authenticate."
}

resource "tfe_variable" "tfc_vault_namespace" {
  workspace_id = tfe_workspace.vault_backed.id

  key      = "TFC_VAULT_NAMESPACE"
  value    = var.vault_namespace
  category = "env"

  description = "Namespace that contains the GCP Secrets Engine."
}

resource "tfe_variable" "enable_gcp_provider_auth" {
  workspace_id = tfe_workspace.vault_backed.id

  key      = "TFC_VAULT_BACKED_GCP_AUTH"
  value    = "true"
  category = "env"

  description = "Enable the Vault Secrets Engine integration for GCP."
}

resource "tfe_variable" "tfc_gcp_mount_path" {
  workspace_id = tfe_workspace.vault_backed.id

  key      = "TFC_VAULT_BACKED_GCP_MOUNT_PATH"
  value    = "gcp"
  category = "env"

  description = "Path to where the GCP Secrets Engine is mounted in Vault."
}

resource "tfe_variable" "tfc_gcp_auth_type" {
  workspace_id = tfe_workspace.vault_backed.id

  key      = "TFC_VAULT_BACKED_GCP_AUTH_TYPE"
  value    = "roleset/access_token"
  category = "env"

  description = "Type of credential to acquire via the GCP Secrets Engine in Vault."
}

resource "tfe_variable" "tfc_gcp_plan_vault_roleset" {
  workspace_id = tfe_workspace.vault_backed.id

  key      = "TFC_VAULT_BACKED_GCP_PLAN_VAULT_ROLESET"
  value    = var.tfc_gcp_plan_vault_roleset
  category = "env"

  description = "Id of the GCP roleset the plan will assume."
}

resource "tfe_variable" "tfc_gcp_apply_vault_roleset" {
  workspace_id = tfe_workspace.vault_backed.id

  key      = "TFC_VAULT_BACKED_GCP_APPLY_VAULT_ROLESET"
  value    = var.tfc_gcp_apply_vault_roleset
  category = "env"

  description = "Id of the GCP roleset the apply will assume."
}

### DIRECT WORKSPACE ###
resource "tfe_workspace" "direct" {
  name         = "direct"
  organization = var.tfc_organization_name
  project_id   = data.tfe_project.tfc_project.id
  working_directory = "terraform-workspaces/direct"
  queue_all_runs = false
  vcs_repo {
    branch             = "main"
    identifier         = "djschnei21/morgan-gcp-demo"
    oauth_token_id     = "ot-95PZayu7N11cQW7H"
  }
}

### DIRECT WORKSPACE VARIABLES ###
resource "tfe_variable" "enable_direct_gcp_provider_auth" {
  workspace_id = tfe_workspace.direct.id
  key      = "TFC_GCP_PROVIDER_AUTH"
  value    = "true"
  category = "env"

  description = "Enable the GCP provider authentication."
}

resource "tfe_variable" "direct_gcp_run_service_account_email" {
  workspace_id = tfe_workspace.direct.id

  key      = "TFC_GCP_RUN_SERVICE_ACCOUNT_EMAIL"
  value    = "hcp-tf-wif-sa-c017@hashicorp-demos-476611.iam.gserviceaccount.com"
  category = "env"

  description = "The Service Account email to use for GCP provider authentication."
}

resource "tfe_variable" "direct_gcp_workload_provider_name" {
  workspace_id = tfe_workspace.direct.id

  key      = "TFC_GCP_WORKLOAD_PROVIDER_NAME"
  value    = "projects/585950547917/locations/global/workloadIdentityPools/hcp-tf-wif-pool-c017/providers/hcp-tf-wif-provider"
  category = "env"

  description = "The Workload Identity Provider to use for GCP provider authentication."
  
}