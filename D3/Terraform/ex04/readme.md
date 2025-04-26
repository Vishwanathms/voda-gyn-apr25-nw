Here’s a **Terraform snippet** that demonstrates **switching from a Single-site to a Multi-site listener** on an **Azure Application Gateway**:

---

### ✅ Prerequisites:
- Your Application Gateway already exists with SSL certificate uploaded (for HTTPS)
- You want to **route traffic based on hostname**

---

### 🛠️ **1. Multi-site HTTPS Listener**
```hcl
resource "azurerm_application_gateway_listener" "multi_site_listener" {
  name                           = "multi-site-https-listener"
  application_gateway_name       = azurerm_application_gateway.example.name
  resource_group_name            = azurerm_resource_group.example.name
  frontend_ip_configuration_name = "appGatewayFrontendIP"
  frontend_port_name             = "https-port"
  protocol                       = "Https"
  ssl_certificate_name           = "ssl-cert"
  host_name                      = "api.contoso.com"  # Multi-site key: host header
  require_sni                    = true
}
```

---

### 🛠️ **2. Backend Pool**
```hcl
resource "azurerm_application_gateway_backend_address_pool" "api_pool" {
  name                = "api-backend-pool"
  resource_group_name = azurerm_resource_group.example.name
  application_gateway_name = azurerm_application_gateway.example.name

  backend_addresses {
    ip_address = "10.0.1.4"
  }
}
```

---

### 🛠️ **3. HTTP Settings**
```hcl
resource "azurerm_application_gateway_http_settings" "api_http_setting" {
  name                           = "api-http-setting"
  resource_group_name            = azurerm_resource_group.example.name
  application_gateway_name       = azurerm_application_gateway.example.name
  cookie_based_affinity          = "Disabled"
  port                           = 443
  protocol                       = "Https"
  request_timeout                = 20
  pick_host_name_from_backend_address = false
}
```

---

### 🛠️ **4. Routing Rule (Multi-site)**
```hcl
resource "azurerm_application_gateway_url_path_map" "api_path_map" {
  name                           = "multi-site-path-map"
  resource_group_name            = azurerm_resource_group.example.name
  application_gateway_name       = azurerm_application_gateway.example.name

  default_backend_address_pool_id = azurerm_application_gateway_backend_address_pool.api_pool.id
  default_backend_http_settings_id = azurerm_application_gateway_http_settings.api_http_setting.id

  path_rule {
    name                       = "api-route"
    paths                      = ["/"]
    backend_address_pool_id    = azurerm_application_gateway_backend_address_pool.api_pool.id
    backend_http_settings_id   = azurerm_application_gateway_http_settings.api_http_setting.id
  }
}

resource "azurerm_application_gateway_request_routing_rule" "multi_site_rule" {
  name                           = "multi-site-routing-rule"
  resource_group_name            = azurerm_resource_group.example.name
  application_gateway_name       = azurerm_application_gateway.example.name
  rule_type                      = "Basic"
  http_listener_id               = azurerm_application_gateway_listener.multi_site_listener.id
  url_path_map_id                = azurerm_application_gateway_url_path_map.api_path_map.id
  priority                       = 10
}
```

---

### 🧾 Notes:
- To switch **back to single-site**, just remove `host_name`, set `require_sni = false`, and update routing to use default rule with no host header checks.
- You can add multiple listeners for different domains (`api.contoso.com`, `app.contoso.com`, etc.) all on the same frontend IP and port if you use **multi-site** properly.

