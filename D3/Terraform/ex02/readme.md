Here’s a `README.md` file that clearly documents your Terraform project to deploy an Azure infrastructure setup with a virtual network, Ubuntu VM, Azure Firewall, and policy-based traffic control.

---

### 📄 `README.md`

```markdown
# Terraform Azure Infrastructure: VM with Firewall and Policy Control

This Terraform project provisions an Azure environment consisting of:

- Resource Group
- Virtual Network with Subnets
- Azure Linux VM (Ubuntu 24.04)
- Azure Firewall
- Azure Firewall Policy (Allow all traffic except blocking access to "yahoo.com")

## 🧱 Architecture Overview

```plaintext
+------------------+
| Resource Group   |
| rg-firewall-demo |
+------------------+
         |
         |
+------------------+
| Virtual Network  |
| vnet-demo        |
+------------------+
   |             |
   |             +---------------------------+
   |                                         |
+-----------+                    +----------------------------+
| Subnet    |                    | AzureFirewallSubnet        |
| (10.0.1.0)|<---- VM NIC ------>| (10.0.2.0/24)              |
+-----------+                    +----------------------------+
                                      |
                                      v
                           +--------------------------+
                           | Azure Firewall (Standard)|
                           +--------------------------+
                                      |
                           +----------------------------+
                           | Firewall Policy           |
                           | - Allow All Traffic       |
                           | - Deny Access to Yahoo.com|
                           +----------------------------+
```

## 📦 Resources Deployed

- **Resource Group:** `rg-firewall-demo`
- **Virtual Network:** `vnet-demo` with 2 subnets
  - Application Subnet (`10.0.1.0/24`)
  - AzureFirewallSubnet (`10.0.2.0/24`)
- **Azure Firewall:** with static public IP and attached firewall policy
- **Firewall Policy:**
  - **Allow:** All HTTP/HTTPS traffic (`*`)
  - **Deny:** Specific FQDN `yahoo.com`
- **Virtual Machine:**
  - OS: Ubuntu Server 24.04 LTS
  - Username: `azureuser`
  - Password: `Azure12345678!` (update before production use)

