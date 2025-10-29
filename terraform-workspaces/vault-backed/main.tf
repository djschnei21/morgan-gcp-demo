provider "google" {
  project     = "hashicorp-demos-476611"
  region      = "us-central1"
}

resource "google_storage_bucket" "no-public-access" {
  name          = "no-public-access-bucket"
  location      = "US"
  force_destroy = true

  public_access_prevention = "enforced"
}