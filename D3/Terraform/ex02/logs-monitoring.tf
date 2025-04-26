data "azurerm_network_watcher" "existing" {
  name                = "NetworkWatcher_eastus"
  resource_group_name = "NetworkWatcherRG"
}

resource "azurerm_log_analytics_workspace" "log" {
  name                = "log-workspace"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_diagnostic_setting" "firewall_logs" {
  name                       = "fw-logs"
  target_resource_id         = azurerm_firewall.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log.id

  enabled_log {
    category = "AzureFirewallApplicationRule"
  }
  enabled_log {
    category = "AzureFirewallNetworkRule"
  }
  enabled_log {
    category = "AzureFirewallDnsProxy"
  }
  # enabled_log {
  #   category = "AzureFirewallThreatIntel"
  # }
}

resource "azurerm_monitor_diagnostic_setting" "bastion_logs" {
  name                       = "bastion-logs"
  target_resource_id         = azurerm_bastion_host.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log.id

  enabled_log {
    category = "BastionAuditLogs"
  }
}


resource "azurerm_network_watcher_flow_log" "vm_nsg_flow_log" {
  network_watcher_name      = data.azurerm_network_watcher.existing.name
  resource_group_name       = data.azurerm_network_watcher.existing.resource_group_name
  name                      = "nsg-flow-log"
  network_security_group_id = azurerm_network_security_group.vm_nsg.id

  storage_account_id = azurerm_storage_account.flowlogs.id
  retention_policy {
    enabled = true
    days = 7
  }
  enabled = true
  version = 2
}

resource "azurerm_storage_account" "flowlogs" {
  name                     = "flowlogstorage${random_id.unique.hex}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "random_id" "unique" {
  byte_length = 4
}


