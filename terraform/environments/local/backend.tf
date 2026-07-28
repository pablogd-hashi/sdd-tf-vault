terraform {
  backend "local" {
    path = "../../.terraform-platform.tfstate"
  }
}
