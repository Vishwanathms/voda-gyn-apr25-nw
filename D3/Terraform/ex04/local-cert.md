To create a `.pfx` certificate locally for use with Azure Application Gateway, you can use **OpenSSL**. Here's how to do it in a few steps:

---

### 🛠️ Step-by-step: Generate `cert.pfx` with OpenSSL

#### ✅ 1. Install OpenSSL
- **Linux/macOS**: usually pre-installed.
- **Windows**: [Download from here](https://slproweb.com/products/Win32OpenSSL.html)

---

#### ✅ 2. Create the Certificate Files

Open a terminal (or Git Bash/PowerShell) and run:

```bash
# Step 1: Create a private key
openssl genrsa -out contoso.key 2048

# Step 2: Create a certificate signing request (CSR)
openssl req -new -key contoso.key -out contoso.csr -subj "//CN=api.contoso.com"

# Step 3: Self-sign the certificate (valid for 2 years)
openssl x509 -req -days 730 -in contoso.csr -signkey contoso.key -out contoso.crt
```
Output
```
ADMIN@DESKTOP-O7MI7ID MINGW64 /e/vcl-data/Business/Training/Gynosis/mar-25/Content (main)
$ openssl req -new -key contoso.key -out contoso.csr -subj "//CN=api.contoso.com"

ADMIN@DESKTOP-O7MI7ID MINGW64 /e/vcl-data/Business/Training/Gynosis/mar-25/Content (main)
$ openssl x509 -req -days 730 -in contoso.csr -signkey contoso.key -out contoso.crt
Signature ok
subject=CN = api.contoso.com
Getting Private key
```


---

#### ✅ 3. Create the `.pfx` File

```bash
openssl pkcs12 -export -out cert.pfx -inkey contoso.key -in contoso.crt -password pass:Pfxpass123
```

> Replace `YourPfxPassword123` with the same value you're using in Terraform.

---

### 🧪 Result
This will generate:
- `cert.pfx` → used in your Terraform code
- Valid for domain `api.contoso.com` (used in listener host_name)

---

Let me know if you want to include both `api.contoso.com` and `app.contoso.com` in a **wildcard or SAN cert** instead.