provider "google" {
  project = "testing" ## Need to give our Project name
  region  = "us-central1"
}

resource "google_storage_bucket" "my_bucket" {
  name     = "my-unique-bucket-name-test-12"  # Ensure this is the unique bucket name
  location = "US"
}
