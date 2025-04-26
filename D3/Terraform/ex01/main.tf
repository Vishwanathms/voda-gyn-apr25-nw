provider "azurerm" {
    features { 
    }
    subscription_id = "3f310de7-7dd2-4e3d-96bf-bc925e1f96f5"
}

terraform {
  backend "azurerm" {
    storage_account_name = "sttfstate23042025"
    container_name = "tfstate"
    key = "vishwa.tfstate"
    resource_group_name = "rg-student-19"
    subscription_id = "3f310de7-7dd2-4e3d-96bf-bc925e1f96f5"
  }
}

resource "azurerm_resource_group" "name" {
  name = "rg-vishwa-01-tf"
  location = "EAST US"
  tags = {
    "name" = "rg01"
    "Owner" = "Vishwa"
    "Env" = "Dev"
  }
}

