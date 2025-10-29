provider "google" {
  project = var.gcp_project_id
}

resource "random_id" "hcp_tf_wif_id" {
  byte_length = 2
}

resource "google_project_service" "services" {
  for_each           = toset(var.activate_apis)
  service            = each.value
  disable_on_destroy = false
}

resource "google_iam_workload_identity_pool" "hcp_tf_wif_pool" {
  workload_identity_pool_id = "${var.app_prefix}-pool-${random_id.hcp_tf_wif_id.hex}"
}

resource "google_iam_workload_identity_pool_provider" "hcp_tf_wif_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.hcp_tf_wif_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "${var.app_prefix}-provider"
  attribute_mapping = {
    "google.subject"                         = "assertion.sub"
    "attribute.terraform_organization_id"    = "assertion.terraform_organization_id"
    "attribute.terraform_project_id"         = "assertion.terraform_project_id"
    "attribute.terraform_workspace_id"       = "assertion.terraform_workspace_id"
    "attribute.terraform_workspace_name"     = "assertion.terraform_workspace_name"
    "attribute.terraform_run_phase"          = "assertion.terraform_run_phase"
  }
  oidc {
    issuer_uri        = var.public_oidc_issuer_url
    allowed_audiences = ["HCP_TERRAFORM_WORKLOAD_IDENTITY"]
  }
  attribute_condition = "assertion.sub.startsWith(\"organization:${var.tfc_organization_name}\")"
}


resource "google_service_account" "hcp_tf_wif" {
  account_id   = "${var.app_prefix}-sa-${random_id.hcp_tf_wif_id.hex}"
  display_name = "HCP Terraform WIF Service Account"
}

resource "google_service_account_iam_member" "vault_plugin_wif_member_plan" {
  service_account_id = google_service_account.hcp_tf_wif.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/585950547917/locations/global/workloadIdentityPools/hcp-tf-wif-pool-c017/attribute.terraform_workspace_name/direct"
}

resource "google_project_iam_custom_role" "hcp_tf_wif_gcp_secret" {
  role_id     = "HCPTerraformRole"
  title       = "HCP Terraform Role"
  description = "A custom IAM role for HCP Terraform."
  permissions = var.hcp_gcp_secret_permissions
}

resource "google_project_iam_member" "hcp_tf_wif_gcp_secret" {
  project = var.gcp_project_id
  role    = google_project_iam_custom_role.hcp_tf_wif_gcp_secret.name
  member  = google_service_account.hcp_tf_wif.member
}
