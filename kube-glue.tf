# Configure the Google Cloud provider
provider "google" {
  project = "hopeful-timing-418011"  # Replace with your Project ID
  region  = "us-central1"  # Or your preferred region
  zone    = "us-central1-a"  # Or your preferred zone
}

# Create a Google Cloud Storage Bucket for data storage (similar to AWS S3)
resource "google_storage_bucket" "my_bucket" {
  name     = "my-unique-bucket-name-test-123"  # Replace with a unique bucket name
  location = "US"
}

# Define the VPC network for GKE and Dataproc clusters
resource "google_compute_network" "vpc_network" {
  name = "shared-network"
}

# Define the subnet for the clusters
resource "google_compute_subnetwork" "subnetwork" {
  name          = "shared-subnetwork"
  ip_cidr_range = "10.0.0.0/16"
  region        = "us-central1"  # Must match provider region
  network       = google_compute_network.vpc_network.name
}

# Create a Dataproc Cluster (equivalent to AWS Glue for data processing)
resource "google_dataproc_cluster" "dataproc_cluster" {
  name   = "dataproc-cluster"
  region = "us-central1"  # Must match the provider's region

  cluster_config {
    # Specify the network and subnetwork
    network_uri    = google_compute_network.vpc_network.self_link
    subnetwork_uri = google_compute_subnetwork.subnetwork.self_link

    master_config {
      num_instances = 1
      machine_type  = "n1-standard-1"
      disk_config {
        boot_disk_size_gb = 100
      }
    }

    worker_config {
      num_instances = 2
      machine_type  = "n1-standard-1"
      disk_config {
        boot_disk_size_gb = 100
      }
    }
  }
}

# Create a Docker Image Registry (equivalent to AWS ECR) using Artifact Registry
resource "google_artifact_registry_repository" "docker_registry" {
  provider = google

  location      = "us-central1"  # Must match the provider's region
  repository_id = "my-docker-repo"
  description   = "Docker repository for storing container images"
  format        = "DOCKER"
}

# Define the GKE Cluster for Kubernetes workloads
resource "google_container_cluster" "gke_cluster" {
  name     = "gke-cluster"
  location = "us-central1"  # Should match the provider's region

  networking_mode = "VPC_NATIVE"

  # VPC and Subnetwork specification
  network    = google_compute_network.vpc_network.self_link
  subnetwork = google_compute_subnetwork.subnetwork.self_link

  # Master network configuration
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "all networks"
    }
  }

  # Node pool configuration
  node_config {
    machine_type = "e2-medium"
    disk_size_gb = 50
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  initial_node_count = 2  # Number of nodes in the cluster
}

# Output the Dataproc Cluster details
output "dataproc_cluster_id" {
  value = google_dataproc_cluster.dataproc_cluster.id
}

# Output the Artifact Registry Repository URL
output "artifact_registry_repository_url" {
  value = google_artifact_registry_repository.docker_registry.repository_url
}

# Output the GKE Cluster endpoint
output "kubernetes_endpoint" {
  value = google_container_cluster.gke_cluster.endpoint
}

# Output the GKE Cluster's cluster CA certificate
output "kubernetes_cluster_ca_certificate" {
  value = google_container_cluster.gke_cluster.master_auth.0.cluster_ca_certificate
}
