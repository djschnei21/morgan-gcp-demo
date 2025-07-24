terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.45.0"
    }
  }
}

provider "google" {
  project     = "hc-ec2367a30f42472eb1834003fee"
  region      = "us-east1"
}