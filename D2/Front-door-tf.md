## 🔁 Terraform Equivalent

Now, let’s translate this to Terraform.

### Required Providers
```hcl
provider "azurerm" {
  features {}
}
```

---

### 1. Front Door Profile
```hcl
resource "azurerm_cdn_frontdoor_profile" "fd_profile" {
  name                = "fd-vishwa-01"
  resource_group_name = "YOUR_RESOURCE_GROUP"
  sku_name            = "Standard_AzureFrontDoor"
  location            = "Global"
}
```

---

### 2. Endpoint
```hcl
resource "azurerm_cdn_frontdoor_endpoint" "fd_endpoint" {
  name                = "fd-ep01"
  profile_name        = azurerm_cdn_frontdoor_profile.fd_profile.name
  resource_group_name = "YOUR_RESOURCE_GROUP"
}
```

---

### 3. Origin Group & Origin
```hcl
resource "azurerm_cdn_frontdoor_origin_group" "origin_group" {
  name                = "origin-group"
  profile_name        = azurerm_cdn_frontdoor_profile.fd_profile.name
  resource_group_name = "YOUR_RESOURCE_GROUP"

  load_balancing {
    sample_size                        = 4
    successful_samples_required        = 3
    additional_latency_in_milliseconds = 50
  }

  health_probe {
    protocol       = "Http"
    path           = "/"
    interval_in_seconds = 100
    request_type   = "HEAD"
  }
}

resource "azurerm_cdn_frontdoor_origin" "origin1" {
  name                = "origin1"
  profile_name        = azurerm_cdn_frontdoor_profile.fd_profile.name
  origin_group_name   = azurerm_cdn_frontdoor_origin_group.origin_group.name
  resource_group_name = "YOUR_RESOURCE_GROUP"

  host_name = "13.13.13.13"
  http_port = 80
  https_port = 443
  origin_host_header = "13.13.13.13"
  priority = 1
  weight   = 1000
  enabled  = true
}
```

---

### 4. WAF Policy
```hcl
resource "azurerm_frontdoor_firewall_policy" "waf" {
  name                = "wafpolicy01"
  resource_group_name = "YOUR_RESOURCE_GROUP"
  location            = "Global"

  policy_settings {
    mode = "Detection"
  }

  sku_name = "Standard_AzureFrontDoor"
}
```

---

### 5. Security Policy (not directly supported in Terraform yet)  
> This part may need to be manually attached through the portal or use an ARM template/CLI workaround until Terraform supports it natively.

---

### 6. Route
```hcl
resource "azurerm_cdn_frontdoor_route" "route1" {
  name                 = "route1"
  profile_name         = azurerm_cdn_frontdoor_profile.fd_profile.name
  endpoint_name        = azurerm_cdn_frontdoor_endpoint.fd_endpoint.name
  resource_group_name  = "YOUR_RESOURCE_GROUP"
  origin_group_name    = azurerm_cdn_frontdoor_origin_group.origin_group.name

  supported_protocols  = ["Http", "Https"]
  https_redirect_enabled = true
  forwarding_protocol    = "MatchRequest"

  patterns_to_match = ["/*", "/users"]
}
```
