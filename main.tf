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