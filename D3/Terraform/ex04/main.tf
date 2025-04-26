provider "azurerm" {
    features { 
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    }
    subscription_id = "3f310de7-7dd2-4e3d-96bf-bc925e1f96f5"
}

resource "azurerm_resource_group" "example" {
  name     = "rg-appgw-demo"
  location = "East US"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-demo"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "frontend" {
  name                 = "frontend-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "example" {
  name                = "appgw-public-ip"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_web_application_firewall_policy" "example" {
  name                = "appgw-waf-policy"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  policy_settings {
    enabled                     = true
    mode                        = "Prevention"
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }

  custom_rules {
    name      = "BlockMaliciousUserAgent"
    priority  = 1
    rule_type = "MatchRule"
    match_conditions {
      match_variables {
        variable_name = "RequestHeaders"
        selector      = "User-Agent"
      }
      operator           = "Contains"
      match_values       = ["BadBot"]
      negation_condition = false
    }
    action = "Block"
  }
}

resource "azurerm_application_gateway" "example" {
  name                = "appgw-demo"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  firewall_policy_id  = azurerm_web_application_firewall_policy.example.id

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = azurerm_subnet.frontend.id
  }

  frontend_port {
    name = "https-port"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "appGatewayFrontendIP"
    public_ip_address_id = azurerm_public_ip.example.id
  }

  ssl_certificate {
    name     = "ssl-cert"
    data     = filebase64("cert.pfx")
    password = "Pfxpass123"
  }

  backend_http_settings {
    name                  = "api-http-setting"
    cookie_based_affinity = "Disabled"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 20
  }

  backend_http_settings {
    name                  = "app-http-setting"
    cookie_based_affinity = "Disabled"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 20
  }

  http_listener {
    name                           = "api-https-listener"
    frontend_ip_configuration_name = "appGatewayFrontendIP"
    frontend_port_name             = "https-port"
    protocol                       = "Https"
    ssl_certificate_name           = "ssl-cert"
    host_name                      = "api.contoso.com"
    require_sni                    = true
  }

  http_listener {
    name                           = "app-https-listener"
    frontend_ip_configuration_name = "appGatewayFrontendIP"
    frontend_port_name             = "https-port"
    protocol                       = "Https"
    ssl_certificate_name           = "ssl-cert"
    host_name                      = "app.contoso.com"
    require_sni                    = true
  }

  backend_address_pool {
    name         = "api-backend-pool"
    ip_addresses = ["10.0.1.4"]
  }

  backend_address_pool {
    name         = "app-backend-pool"
    ip_addresses = ["10.0.1.5"]
  }

  request_routing_rule {
    name                       = "api-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "api-https-listener"
    backend_address_pool_name  = "api-backend-pool"
    backend_http_settings_name = "api-http-setting"
    priority                   = 10
  }

  request_routing_rule {
    name                       = "app-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "app-https-listener"
    backend_address_pool_name  = "app-backend-pool"
    backend_http_settings_name = "app-http-setting"
    priority                   = 20
  }
}