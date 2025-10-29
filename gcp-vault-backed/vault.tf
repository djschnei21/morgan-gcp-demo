provider "vault" {}


resource "vault_namespace" "wif_namespace" {
  path        = "gcp_wif"
}

locals {
  identity_token_audience = "https://iam.googleapis.com/${google_iam_workload_identity_pool.vault_plugin_wif_pool.name}/providers/${var.app_prefix}-provider"
}

resource "vault_identity_oidc" "issuer_url" {
  issuer = var.public_oidc_issuer_url
  namespace = vault_namespace.wif_namespace.path_fq
}

resource "vault_identity_oidc_key" "plugin_wif" {
  namespace = vault_namespace.wif_namespace.path_fq
  name               = "plugin-wif-key"
  rotation_period    = 60 * 60 * 24 * 90 # 90 days
  verification_ttl   = 60 * 60 * 24      # 24 hours
  algorithm          = "RS256"
  allowed_client_ids = [local.identity_token_audience]
}

resource "vault_gcp_secret_backend" "plugin_wif" {
  namespace = vault_namespace.wif_namespace.path_fq
  identity_token_key         = vault_identity_oidc_key.plugin_wif.id
  identity_token_ttl         = 60 * 30 # 30 minutes
  identity_token_audience    = local.identity_token_audience
  service_account_email      = "${var.app_prefix}-sa-${random_id.vault_plugin_wif_id.hex}@${var.gcp_project_id}.iam.gserviceaccount.com"
  default_lease_ttl_seconds  = 60 * 30     # 30 minutes
  max_lease_ttl_seconds      = 60 * 60 * 2 # 2 hours
}

resource "vault_gcp_secret_roleset" "viewer_token_roleset" {
  namespace = vault_namespace.wif_namespace.path_fq
  backend      = vault_gcp_secret_backend.plugin_wif.path
  roleset      = "project_viewer_token"
  secret_type  = "access_token"
  project      = var.gcp_project_id
  token_scopes = ["https://www.googleapis.com/auth/cloud-platform"]

  binding {
    resource = "//cloudresourcemanager.googleapis.com/projects/${var.gcp_project_id}"
    roles = [
      "roles/viewer",
    ]
  }
}

resource "vault_gcp_secret_roleset" "owner_token_roleset" {
  namespace = vault_namespace.wif_namespace.path_fq
  backend      = vault_gcp_secret_backend.plugin_wif.path
  roleset      = "project_owner_token"
  secret_type  = "access_token"
  project      = var.gcp_project_id
  token_scopes = ["https://www.googleapis.com/auth/cloud-platform"]

  binding {
    resource = "//cloudresourcemanager.googleapis.com/projects/${var.gcp_project_id}"
    roles = [
      "roles/owner",
    ]
  }
}

resource "vault_jwt_auth_backend" "tfc_jwt" {
  namespace = vault_namespace.wif_namespace.path_fq
  path               = var.jwt_backend_path
  type               = "jwt"
  oidc_discovery_url = "https://${var.tfc_hostname}"
  bound_issuer       = "https://${var.tfc_hostname}"
}

resource "vault_jwt_auth_backend_role" "tfc_role_plan" {
  namespace = vault_namespace.wif_namespace.path_fq
  backend        = vault_jwt_auth_backend.tfc_jwt.path
  role_name      = "tfc-role-plan"
  token_policies = [vault_policy.tfc_policy_plan.name]

  bound_audiences   = [var.tfc_vault_audience]
  bound_claims_type = "glob"
  bound_claims = {
    sub = "organization:${var.tfc_organization_name}:project:${var.tfc_project_name}:workspace:*:run_phase:plan"
  }
  user_claim = "terraform_full_workspace"
  role_type  = "jwt"
  token_ttl  = 1200
}

resource "vault_jwt_auth_backend_role" "tfc_role_apply" {
  namespace = vault_namespace.wif_namespace.path_fq
  backend        = vault_jwt_auth_backend.tfc_jwt.path
  role_name      = "tfc-role-apply"
  token_policies = [vault_policy.tfc_policy_apply.name]

  bound_audiences   = [var.tfc_vault_audience]
  bound_claims_type = "glob"
  bound_claims = {
    sub = "organization:${var.tfc_organization_name}:project:${var.tfc_project_name}:workspace:*:run_phase:apply"
  }
  user_claim = "terraform_full_workspace"
  role_type  = "jwt"
  token_ttl  = 1200
}

resource "vault_policy" "tfc_policy_plan" {
  namespace = vault_namespace.wif_namespace.path_fq
  name = "tfc-policy-plan"

  policy = <<EOT
# Allow tokens to query themselves
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

# Allow tokens to renew themselves
path "auth/token/renew-self" {
    capabilities = ["update"]
}

# Allow tokens to revoke themselves
path "auth/token/revoke-self" {
    capabilities = ["update"]
}

# Allow Access to GCP Secrets Engine
path "gcp/roleset/${vault_gcp_secret_roleset.viewer_token_roleset.roleset}/token" {
    capabilities = ["read"]
}
EOT
}

resource "vault_policy" "tfc_policy_apply" {
  namespace = vault_namespace.wif_namespace.path_fq
  name = "tfc-policy-apply"

  policy = <<EOT
# Allow tokens to query themselves
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

# Allow tokens to renew themselves
path "auth/token/renew-self" {
    capabilities = ["update"]
}

# Allow tokens to revoke themselves
path "auth/token/revoke-self" {
    capabilities = ["update"]
}
  
path "/gcp/roleset/${vault_gcp_secret_roleset.owner_token_roleset.roleset}/token" {
    capabilities = ["read"]
}
EOT
}