# Configure the Google Cloud provider
provider "google" {
  project = "hopeful-timing-418011"  # Replace with your Project ID
  region  = "us-central1"  # Or your preferred region
  zone    = "us-central1-a"  # Or your preferred zone
}

# Create a Google Cloud Storage Bucket
resource "google_storage_bucket" "my_bucket" {
  name     = "my-unique-bucket-name-test-123"  # Replace with a unique bucket name
  location = "US"
}

# Define the VPC network for the GKE cluster (optional, or use default)
resource "google_compute_network" "vpc_network" {
  name = "gke-network"
}

# Define the subnet for the GKE cluster
resource "google_compute_subnetwork" "subnetwork" {
  name          = "gke-subnetwork"
  ip_cidr_range = "10.0.0.0/16"
  region        = "us-central1"  # Must match provider region
  network       = google_compute_network.vpc_network.name
}

# Define the GKE Cluster with reduced resource requirements
resource "google_container_cluster" "primary" {
  name     = "gke-cluster"
  location = "us-central1"  # This should match the provider's region

  # Use VPC-native mode
  networking_mode = "VPC_NATIVE"

  # Master network configuration
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "all networks"
    }
  }

  # Node pool configuration with reduced machine type and disk size
  node_config {
    machine_type = "e2-medium"  # Choose a smaller machine type
    disk_size_gb = 50  # Reduce disk size to 50GB to fit within quota
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  initial_node_count = 2  # Reduce the number of nodes to fit within resource limits

  # Subnetwork specification
  network    = google_compute_network.vpc_network.name
  subnetwork = google_compute_subnetwork.subnetwork.name
}

# Output the GKE Cluster endpoint
output "kubernetes_endpoint" {
  value = google_container_cluster.primary.endpoint
}

# Output the GKE Cluster's cluster CA certificate
output "kubernetes_cluster_ca_certificate" {
  value = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
}
