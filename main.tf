provider "azurerm" {
  features = {}
}

resource "azurerm_resource_group" "aks_rg" {
  name     = "aks-resource-group"
  location = "East US"
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "aks-cluster"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "aks-cluster"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  service_principal {
    client_id     = "MY_CLIENT_ID"
    client_secret = "MY_CLIENT_SECRET"
  }

  tags = {
    environment = "production"
  }
}

resource "time_sleep" "wait_for_cluster" {
  depends_on = [azurerm_kubernetes_cluster.aks_cluster]

  create_duration = "5m"
}

# Helm installation

resource "helm_release" "weaviate" {
  name       = "weaviate"
  repository = "https://MY_WEAVIATE_REPO_URL"
  chart      = "weaviate-chart"
  namespace  = "default"
  timeout    = 300

  values = [
    // Add your values here
  ]
}

# Test script

resource "null_resource" "weaviate_test" {
  depends_on = [helm_release.weaviate]

  provisioner "local-exec" {
    command = "bash ${path.module}/weaviate_test.sh"
  }
}