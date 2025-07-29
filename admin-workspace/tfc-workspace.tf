# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "tfe" {
  hostname = var.tfc_hostname
}

# Data source used to grab the project under which a workspace will be created.
#
# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/data-sources/project
data "tfe_project" "tfc_project" {
  name         = var.tfc_project_name
  organization = var.tfc_organization_name
}

# Runs in this workspace will be automatically authenticated
# to Vault with the permissions set in the Vault policy.
#
# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/workspace
resource "tfe_workspace" "my_workspace" {
  count = var.create_workspace ? 1 : 0
  force_delete = true
  name         = var.tfc_workspace_name
  organization = var.tfc_organization_name
  project_id   = data.tfe_project.tfc_project.id
}

# The following variables must be set to allow runs
# to authenticate to GCP.
#
# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable
resource "tfe_variable" "enable_vault_provider_auth" {
  count = var.create_workspace ? 1 : 0
  workspace_id = tfe_workspace.my_workspace[count.index].id

  key      = "TFC_VAULT_PROVIDER_AUTH"
  value    = "true"
  category = "env"

  description = "Enable the Workload Identity integration for Vault."
}

resource "tfe_variable" "tfc_vault_addr" {
  count = var.create_workspace ? 1 : 0
  workspace_id = tfe_workspace.my_workspace[count.index].id

  key       = "TFC_VAULT_ADDR"
  value     = var.vault_url
  category  = "env"
  sensitive = true

  description = "The address of the Vault instance runs will access."
}

resource "tfe_variable" "tfc_vault_role" {
  count = var.create_workspace ? 1 : 0
  workspace_id = tfe_workspace.my_workspace[count.index].id

  key      = "TFC_VAULT_RUN_ROLE"
  value    = vault_jwt_auth_backend_role.tfc_role.role_name
  category = "env"

  description = "The Vault role runs will use to authenticate."
}

resource "tfe_variable" "tfc_vault_namespace" {
  count = var.create_workspace ? 1 : 0
  workspace_id = tfe_workspace.my_workspace[count.index].id

  key      = "TFC_VAULT_NAMESPACE"
  value    = var.vault_namespace
  category = "env"

  description = "Namespace that contains the GCP Secrets Engine."
}

resource "tfe_variable" "enable_gcp_provider_auth" {
  count = var.create_workspace ? 1 : 0
  workspace_id = tfe_workspace.my_workspace[count.index].id

  key      = "TFC_VAULT_BACKED_GCP_AUTH"
  value    = "true"
  category = "env"

  description = "Enable the Vault Secrets Engine integration for GCP."
}

resource "tfe_variable" "tfc_gcp_mount_path" {
  count = var.create_workspace ? 1 : 0
  workspace_id = tfe_workspace.my_workspace[count.index].id

  key      = "TFC_VAULT_BACKED_GCP_MOUNT_PATH"
  value    = "gcp"
  category = "env"

  description = "Path to where the GCP Secrets Engine is mounted in Vault."
}

resource "tfe_variable" "tfc_gcp_auth_type" {
  count = var.create_workspace ? 1 : 0
  workspace_id = tfe_workspace.my_workspace[count.index].id

  key      = "TFC_VAULT_BACKED_GCP_AUTH_TYPE"
  value    = "roleset/${vault_gcp_secret_roleset.gcp_secret_roleset.secret_type}"
  category = "env"

  description = "Type of credential to acquire via the GCP Secrets Engine in Vault."
}

resource "tfe_variable" "tfc_gcp_run_vault_roleset" {
  count = var.create_workspace ? 1 : 0
  workspace_id = tfe_workspace.my_workspace[count.index].id

  key      = "TFC_VAULT_BACKED_GCP_RUN_VAULT_ROLESET"
  value    = vault_gcp_secret_roleset.gcp_secret_roleset.roleset
  category = "env"

  description = "Id of the GCP roleset the run will assume."
}