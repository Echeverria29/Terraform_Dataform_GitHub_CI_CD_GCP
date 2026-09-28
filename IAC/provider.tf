terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.27.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "7.27.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
}

provider "google" {
  project = var.project
}

provider "google-beta" {
  project = var.project
}