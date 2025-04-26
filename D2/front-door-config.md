This Azure Resource Manager (ARM) template defines an **Azure Front Door Standard** setup with routing, WAF (Web Application Firewall), origin groups, and security policies. Let's break it down **section by section**, explaining all the properties and translating it to Terraform.

---

## 🧱 ARM Template Components Breakdown

### 1. **Front Door Profile**
```json
{
  "type": "Microsoft.Cdn/Profiles",
  "name": "fd-vishwa-01",
  "sku": { "name": "Standard_AzureFrontDoor" },
  "location": "Global",
  "properties": {
    "frontDoorId": null,
    "originResponseTimeoutSeconds": 60,
    "extendedProperties": {}
  }
}
```

| Property                         | Description                                                                 |
|----------------------------------|-----------------------------------------------------------------------------|
| `Microsoft.Cdn/Profiles`        | Specifies an Azure Front Door Standard profile                             |
| `sku.name`                      | Specifies the SKU. Here it’s `Standard_AzureFrontDoor`.                     |
| `originResponseTimeoutSeconds` | Max time Front Door waits for a response from the origin (in seconds)      |
| `extendedProperties`           | Reserved for future use. Empty here.                                       |

---

### 2. **Endpoint Definition**
```json
{
  "type": "Microsoft.Cdn/Profiles/AfdEndpoints",
  "name": "fd-vishwa-01/fd-ep01",
  "properties": {
    "hostName": "fd-ep01-<generated>.z01.azurefd.net",
    "enabledState": "Enabled"
  }
}
```

Defines a Front Door endpoint.

| Property      | Description                                              |
|---------------|----------------------------------------------------------|
| `hostName`    | Auto-generated DNS name for your Front Door endpoint     |
| `enabledState`| Enables or disables the endpoint                         |

---

### 3. **Origin Group**
```json
{
  "type": "Microsoft.Cdn/Profiles/OriginGroups",
  "name": "fd-vishwa-01/origin-group",
  "properties": {
    "loadBalancingSettings": { ... },
    "healthProbeSettings": { ... },
    "sessionAffinityState": "Disabled"
  }
}
```

| Section                | Description                                                        |
|------------------------|--------------------------------------------------------------------|
| `loadBalancingSettings`| Controls how traffic is split among origins                        |
| `healthProbeSettings`  | Monitors origin health (path, method, interval)                    |
| `sessionAffinityState` | Ensures sticky sessions (disabled here)                            |

---

### 4. **Origin inside Origin Group**
```json
{
  "type": "Microsoft.Cdn/Profiles/OriginGroups/Origins",
  "name": "fd-vishwa-01/origin-group/origin1",
  "properties": {
    "hostName": "13.13.13.13",
    "httpPort": 80,
    "httpsPort": 443,
    "priority": 1,
    "weight": 1000,
    "enabledState": "Enabled"
  }
}
```

Defines an origin server.

| Property           | Description                                      |
|--------------------|--------------------------------------------------|
| `hostName`         | The backend origin IP or domain                  |
| `priority` & `weight`| For load balancing behavior                     |
| `originHostHeader` | Host header sent to the origin                   |
| `enforceCertificateNameCheck` | SSL verification (true for security)    |

---

### 5. **Web Application Firewall (WAF) Policy**
```json
{
  "type": "Microsoft.Network/frontdoorwebapplicationfirewallpolicies",
  "name": "wafpolicy01",
  "properties": {
    "policySettings": {
      "enabledState": "Enabled",
      "mode": "Detection"
    },
    "managedRules": { "managedRuleSets": [] }
  }
}
```

| Property           | Description                                                  |
|--------------------|--------------------------------------------------------------|
| `mode: Detection`  | Logs requests without blocking (switch to Prevention to block)|
| `managedRuleSets`  | Empty here but typically includes OWASP rule sets            |

---

### 6. **Security Policy**
```json
{
  "type": "Microsoft.Cdn/Profiles/SecurityPolicies",
  "name": "fd-vishwa-01/secpol01",
  "properties": {
    "parameters": {
      "type": "WebApplicationFirewall",
      "wafPolicy": {
        "id": "[resourceId(...)]"
      },
      "associations": [
        {
          "domains": [
            { "id": "[resourceId(...)]" }
          ],
          "patternsToMatch": ["/*"]
        }
      ]
    }
  }
}
```

Attaches the WAF policy to an endpoint.

---

### 7. **Route Configuration**
```json
{
  "type": "Microsoft.Cdn/Profiles/AfdEndpoints/Routes",
  "name": "fd-vishwa-01/fd-ep01/route1",
  "properties": {
    "patternsToMatch": ["/*", "/users"],
    "originGroup": { "id": "[resourceId(...)]" },
    "forwardingProtocol": "MatchRequest",
    "httpsRedirect": "Enabled",
    "enabledState": "Enabled"
  }
}
```

| Property          | Description                                                   |
|-------------------|---------------------------------------------------------------|
| `patternsToMatch` | URI patterns to apply this route to                           |
| `originGroup`     | Link to origin group                                          |
| `httpsRedirect`   | Force HTTP to HTTPS                                           |
| `forwardingProtocol` | Forward using the same protocol as the request            |

---

