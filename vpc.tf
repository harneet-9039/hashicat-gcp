module "network_example_basic_auto_mode" {
  source  = "app.terraform.io/db231/network/google//examples/basic_auto_mode"
  version = "~> 3.2.2"
  # insert required variables here
  network_name = "mynw543"
  project_id = "gcptraining"
  subnets = [
  {
    subnet_name   = "gaurav-subnet"
    subnet_ip     = "10.100.10.0/24"
    subnet_region = var.region
  }
]
}
