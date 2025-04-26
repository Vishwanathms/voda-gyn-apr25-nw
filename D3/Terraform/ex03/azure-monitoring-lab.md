# 🚀 Azure Monitoring Lab with Terraform

This lab sets up a complete Azure monitoring stack using **Terraform**, including:

- ✅ Log Analytics Workspace
- ✅ Application Insights
- ✅ App Service (with App Insights integration)
- ✅ Diagnostic Settings (App Logs to Log Analytics)
- ✅ Azure Event Hub (for streaming telemetry)

---

## 📁 Project Structure

Save the following Terraform code as `main.tf` in your project directory.

You will need to run the following commands:

```bash
terraform init
terraform plan
terraform apply
```

---

## 📦 Resources Created

| Resource Type              | Resource Name         | Description |
|---------------------------|------------------------|-------------|
| Resource Group             | MonitoringLabRG        | Holds all resources |
| Log Analytics Workspace    | logws-demo             | Central log collection |
| App Insights               | appinsights-demo       | Application telemetry |
| App Service Plan           | appserviceplan-demo    | Hosting plan |
| App Service (Web App)      | demoapp-<random>       | Web application |
| Diagnostic Setting         | appservice-diagnostic  | Sends logs to Log Analytics |
| Event Hub Namespace        | eventhubnsdemo-<random>| Event streaming platform |
| Event Hub                  | telemetry-events       | Sample event stream |

---

## 🛠️ App Insights Configuration

The App Service will include the following application settings to integrate with Application Insights:

```json
{
  "APPINSIGHTS_INSTRUMENTATIONKEY": "<from resource>",
  "APPLICATIONINSIGHTS_CONNECTION_STRING": "<from resource>",
  "ApplicationInsightsAgent_EXTENSION_VERSION": "~2"
}
```

These settings enable automatic telemetry collection from the App Service.

---

## 📤 Diagnostic Settings

Diagnostic logs from App Service are sent to Log Analytics Workspace. Enabled categories include:

- `AppServiceHTTPLogs`
- `AppServiceConsoleLogs`
- `AllMetrics`

You can query these logs in Azure Monitor or use **Azure Workbooks** to build dashboards.

---

## 📡 Event Hub (telemetry-events)

An Event Hub is created to simulate a telemetry ingestion pipeline.

- Namespace: `eventhubnsdemo-<random>`
- Event Hub: `telemetry-events`
- Partitions: 2
- Retention: 1 day

You can integrate this Event Hub with:
- Azure Stream Analytics → Log Analytics
- Custom Producer (Python/Node.js) to send device telemetry

---

## 🧪 Next Steps

- Use Kusto Query Language (KQL) in Log Analytics to query App Service metrics.
- Create a **Workbook** in Azure Monitor for visual dashboards.
- Use Azure CLI or SDK to push events to the Event Hub.

Need help with KQL queries or dashboards? Just ask!

---

## 🔐 Prerequisites

Make sure you have:

- Azure CLI authenticated (`az login`)
- Terraform >= 1.3 installed
- Adequate permission to create App Services, Insights, Event Hubs

---

Happy monitoring! 📊