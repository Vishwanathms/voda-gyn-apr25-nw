provider "azurerm" {
    features { 
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    }
    subscription_id = "3f310de7-7dd2-4e3d-96bf-bc925e1f96f5"
}

resource "azurerm_resource_group" "rg" {
  name     = "MonitoringLabRG"
  location = "west US"
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "law" {
  name                = "logws-demo"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Application Insights
resource "azurerm_application_insights" "appinsights" {
  name                = "appinsights-demo"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
  #workspace_id        = azurerm_log_analytics_workspace.law.id
}

# App Service Plan
resource "azurerm_app_service_plan" "plan" {
  name                = "appserviceplan-demo"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku {
    tier = "Standard"
    size = "S1"
  }
}

# App Service (Web App)
resource "azurerm_app_service" "webapp" {
  name                = "demoapp-${random_id.suffix.hex}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.plan.id

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.appinsights.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.appinsights.connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~2"
  }

  depends_on = [azurerm_application_insights.appinsights]
}

# Random suffix for uniqueness
resource "random_id" "suffix" {
  byte_length = 4
}

# Diagnostic Setting to send logs from App Service to Log Analytics
resource "azurerm_monitor_diagnostic_setting" "app_logs" {
  name                       = "appservice-diagnostic"
  target_resource_id         = azurerm_app_service.webapp.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {
    category = "AppServiceHTTPLogs"

    retention_policy {
      enabled = false
      days    = 0
    }
  }

  enabled_log {
    category = "AppServiceConsoleLogs"

    retention_policy {
      enabled = false
      days    = 0
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = false
      days    = 0
    }
  }
}

# Event Hub Namespace
resource "azurerm_eventhub_namespace" "ehns" {
  name                = "eventhubnsdemo${random_id.suffix.hex}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  capacity            = 1
}

# Event Hub
resource "azurerm_eventhub" "eh" {
  name                = "telemetry-events"
  namespace_name      = azurerm_eventhub_namespace.ehns.name
  resource_group_name = azurerm_resource_group.rg.name
  partition_count     = 2
  message_retention   = 1
}
