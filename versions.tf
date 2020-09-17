terraform {
  required_version = "~> 0.13.0"
  
  required_providers {
    local = {
      version = "~> 1.4.0"
      source  = "hashicorp/local"
    }
    null = {
      version = "~> 2.1.2"
      source  = "hashicorp/null"
    }
  }
}
