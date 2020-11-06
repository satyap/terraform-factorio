provider "aws" {
  region  = var.region
  version = "~> 2.13"
  profile = "factorio"
}

provider "template" {
  version = "~> 2.1"
}

provider "tls" {
  version = "~> 2.1"
}

provider "null" {
  version = "~> 2.1"
}
