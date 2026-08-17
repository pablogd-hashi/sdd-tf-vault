terraform {
  backend "local" {
    path = "../../.terraform-platform-kind.tfstate"
  }
}
