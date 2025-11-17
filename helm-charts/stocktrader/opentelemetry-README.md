# OpenTelemetry Integration

This directory contains the OpenTelemetry integration for IBM Stock Trader, providing distributed tracing, metrics, and logging capabilities.

## Overview

The OpenTelemetry integration consists of:
- **Collector Deployment**: Centralized collector that receives, processes, and exports telemetry data
- **Agent DaemonSet**: Optional node-level agents for collecting telemetry
- **Supporting Resources**: ServiceAccounts, ClusterRoles, ConfigMaps, and Secrets

## Architecture

### Components

1. **OpenTelemetry Collector** (`otel-collector-deployment.yaml`)
   - Receives telemetry data from applications via OTLP
   - Processes and exports to configured backends
   - Supports multiple exporters (Azure Monitor, Google Cloud, etc.)
   - Runs as a Deployment with configurable replicas

2. **OpenTelemetry Agent** (`otel-agent-daemonset.yaml`)
   - Optional DaemonSet running on each node
   - Collects node-level telemetry
   - Forwards data to the collector
   - Disabled by default

3. **Configuration** (`otel-collector-config.yaml`)
   - Defines receivers, processors, and exporters
   - Configurable through Helm values

## Prerequisites

### Backend Secrets

Before enabling OpenTelemetry with a backend exporter, you must create the necessary Kubernetes secrets.

#### Azure Monitor

```bash
kubectl create secret generic <release-name>-azuremonitor-secrets \
  --from-literal=connection-string='<your-azure-monitor-connection-string>' \
  -n <namespace>
```

Replace placeholders:
- `<release-name>` - Your Helm release name (e.g., `cjot`)
- `<your-azure-monitor-connection-string>` - Your connection string (format: `InstrumentationKey=...;IngestionEndpoint=...;LiveEndpoint=...;ApplicationId=...`)
- `<namespace>` - Target namespace (e.g., `stocktrader`)

**Example:**
```bash
kubectl create secret generic cjot-azuremonitor-secrets \
  --from-literal=connection-string='InstrumentationKey=12345678-1234-1234-1234-123456789abc;IngestionEndpoint=https://centralus-2.in.applicationinsights.azure.com/;LiveEndpoint=https://centralus.livediagnostics.monitor.azure.com/;ApplicationId=12345678-1234-1234-1234-123456789abc' \
  -n stocktrader
```

#### Google Cloud

```bash
kubectl create secret generic <release-name>-googlecloud-secrets \
  --from-literal=connection-string='<your-service-account-json>' \
  -n <namespace>
```

## Configuration

### Key Parameters

Configure OpenTelemetry through `values.yaml`:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.opentelemetry.disable` | Disable OpenTelemetry completely | `true` |
| `global.opentelemetry.agent.enabled` | Enable agent DaemonSet | `false` |
| `global.opentelemetry.agent.image.repository` | Agent image repository | `ghcr.io/ibmstocktrader/opentelemetry-collector` |
| `global.opentelemetry.agent.image.tag` | Agent image tag | `latest` |
| `global.opentelemetry.collector.replicas` | Number of collector replicas | `1` |
| `global.opentelemetry.collector.endpoint` | Collector endpoint URL | `http://{{ .Release.Name }}-otel-collector:4317` |
| `global.opentelemetry.collector.backends` | Array of backend exporters | See below |
| `global.opentelemetry.serviceName` | Service name for traces | `trader` |
| `global.opentelemetry.logExporter` | Log exporter type | `otlp` |
| `global.opentelemetry.metricExporter` | Metric exporter type | `otlp` |
| `global.opentelemetry.traceExporter` | Trace exporter type | `otlp` |
| `global.opentelemetry.autoscaling.enabled` | Enable HPA for collector | `true` |
| `global.opentelemetry.autoscaling.minReplicas` | Minimum replicas | `1` |
| `global.opentelemetry.autoscaling.maxReplicas` | Maximum replicas | `5` |
| `global.environment` | Environment (affects image selection) | `development` |

### Backend Configuration

Backends are configured as an array in `values.yaml`:

```yaml
global:
  opentelemetry:
    collector:
      backends:
        - kind: azuremonitor
          secretName: "{{ .Release.Name }}-azuremonitor-secrets"
        - kind: googlecloud
          secretName: "{{ .Release.Name }}-googlecloud-secrets"
```

Supported backend kinds:
- `azuremonitor` - Azure Monitor Application Insights
- `googlecloud` - Google Cloud Operations (Stackdriver)

### Image Selection

The collector and agent images are automatically selected based on the `global.environment` value:

- **Production** (`global.environment: production`):
  - Uses images from `values.yaml` configuration
  - Example: `ghcr.io/ibmstocktrader/opentelemetry-collector-contrib:latest`
  
- **Development/Other** (default):
  - Uses community images
  - Collector: `otel/opentelemetry-collector-contrib:latest`
  - Agent: `otel/opentelemetry-collector:latest`

This is controlled by helper functions in `templates/_helpers.tpl`:
- `otel.collector.image` - Returns the appropriate collector image
- `otel.agent.image` - Returns the appropriate agent image

## Installation

### Basic Installation (OpenTelemetry Disabled)

```bash
helm install cjot stocktrader-2.0.0.tgz -n stocktrader
```

### Enable OpenTelemetry with Azure Monitor

1. Create the namespace:
```bash
kubectl create namespace stocktrader
```

2. Create the Azure Monitor secret:
```bash
kubectl create secret generic cjot-azuremonitor-secrets \
  --from-literal=connection-string='InstrumentationKey=...;IngestionEndpoint=...;LiveEndpoint=...;ApplicationId=...' \
  -n stocktrader
```

3. Install with OpenTelemetry enabled:
```bash
helm install cjot stocktrader-2.0.0.tgz \
  -n stocktrader \
  --set global.opentelemetry.disable=false
```

### Enable Agent DaemonSet

To enable the optional agent DaemonSet:

```bash
helm install cjot stocktrader-2.0.0.tgz \
  -n stocktrader \
  --set global.opentelemetry.disable=false \
  --set global.opentelemetry.agent.enabled=true
```

## Verification

After installation, the Helm notes will display the configured OpenTelemetry images:

```
OpenTelemetry Configuration:
  Collector Image: otel/opentelemetry-collector-contrib:latest
  Environment: development
```

### Check Collector Status

```bash
# Check collector deployment
kubectl get deployment <release-name>-otel-collector -n stocktrader

# Check collector pods
kubectl get pods -l component=<release-name>-otel-collector -n stocktrader

# Check collector logs
kubectl logs -l component=<release-name>-otel-collector -n stocktrader
```

### Check Agent Status (if enabled)

```bash
# Check agent daemonset
kubectl get daemonset <release-name>-otel-agent -n stocktrader

# Check agent pods
kubectl get pods -l component=<release-name>-otel-agent -n stocktrader
```

## Troubleshooting

### Collector Not Starting

1. Check if the secret exists:
```bash
kubectl get secret <release-name>-azuremonitor-secrets -n stocktrader
```

2. Verify the secret content:
```bash
kubectl get secret <release-name>-azuremonitor-secrets -n stocktrader -o yaml
```

3. Check collector logs:
```bash
kubectl logs -l component=<release-name>-otel-collector -n stocktrader
```

### No Telemetry Data

1. Verify the collector endpoint is reachable from application pods
2. Check that `global.opentelemetry.disable` is set to `false`
3. Ensure application pods are configured with the correct exporter settings
4. Review collector configuration in the ConfigMap:
```bash
kubectl get configmap <release-name>-otel-collector-conf -n stocktrader -o yaml
```

### Backend Connection Issues

1. Verify the connection string in the secret is correct
2. Check network connectivity from the cluster to the backend service
3. Review backend-specific error messages in collector logs

## Security Considerations

- **Never commit secrets to source control** - Always create secrets separately
- **Use RBAC** - The collector ServiceAccount has minimal required permissions
- **Secret naming** - Must match the pattern in `values.yaml` for proper injection
- **Network policies** - Consider restricting collector network access to necessary backends only

## Files in This Directory

- `otel-collector-deployment.yaml` - Main collector deployment
- `otel-agent-daemonset.yaml` - Optional agent DaemonSet
- `otel-collector-config.yaml` - Collector configuration ConfigMap
- `otel-collector-service.yaml` - Service exposing collector endpoints
- `otel-collector-serviceaccount.yaml` - ServiceAccount for collector
- `otel-collector-clusterrole.yaml` - ClusterRole with required permissions
- `otel-collector-clusterrolebinding.yaml` - Binds ServiceAccount to ClusterRole
- `otel-collector-hpa.yaml` - Horizontal Pod Autoscaler for collector
- `otel-collector-secret.yaml` - Template for backend secrets (commented out)
- `README.md` - This documentation

## References

- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)
- [OpenTelemetry Collector](https://opentelemetry.io/docs/collector/)
- [Azure Monitor OpenTelemetry](https://learn.microsoft.com/en-us/azure/azure-monitor/app/opentelemetry-enable)
- [Google Cloud OpenTelemetry](https://cloud.google.com/trace/docs/setup/opentelemetry)
