# Monitoring Stack Helm Chart

A lightweight, single-pod-per-component monitoring stack for K3s clusters, based on your Docker Compose setup.

## Components

- **Prometheus** (1 pod) - Metrics collection and storage
- **Grafana** (1 pod) - Metrics visualization
- **Loki** (1 pod) - Log aggregation
- **Promtail** (DaemonSet) - Log shipper (one per node)
- **Node Exporter** (DaemonSet) - Node metrics (one per node)
- **Blackbox Exporter** (1 pod) - HTTP/TCP endpoint monitoring
- **Alertmanager** (1 pod) - Alert routing and management

## Prerequisites

- K3s cluster with `local-path` StorageClass (default in K3s)
- kubectl configured to access your cluster
- Helm 3.x

## Installation

### Quick Start

```bash
# Create the monitoring namespace and deploy the chart
helm install monitoring ./monitoring-stack \
  --namespace monitoring \
  --create-namespace

# Verify deployment
kubectl get pods -n monitoring
kubectl get pvc -n monitoring
```

### Using Custom Values

Create a `custom-values.yaml` file to override defaults:

```yaml
prometheus:
  replicas: 1
  persistence:
    size: 20Gi

grafana:
  adminPassword: "your-secure-password"
  persistence:
    size: 5Gi

loki:
  persistence:
    size: 10Gi
```

Then deploy with custom values:

```bash
helm install monitoring ./monitoring-stack \
  --namespace monitoring \
  --create-namespace \
  -f custom-values.yaml
```

## Accessing the Components

### Grafana

```bash
kubectl port-forward -n monitoring svc/grafana 3000:3000
```

Access at `http://localhost:3000`
- Default username: `admin`
- Default password: `admin123` (change in values.yaml!)

### Prometheus

```bash
kubectl port-forward -n monitoring svc/prometheus 9090:9090
```

Access at `http://localhost:9090`

### Alertmanager

```bash
kubectl port-forward -n monitoring svc/alertmanager 9093:9093
```

Access at `http://localhost:9093`

## Configuration

All configuration is managed via `values.yaml`. Key settings:

- **Resource Requests/Limits**: Tuned for K3s edge deployments
- **Storage**: Uses `local-path` StorageClass (default in K3s)
- **Replicas**: All components set to 1 pod
- **Retention**: Prometheus defaults to 7 days

## Adding Prometheus Scrape Targets

Edit the Prometheus ConfigMap in `templates/prometheus-configmap.yaml` to add more scrape jobs. For example:

```yaml
- job_name: 'my-app'
  static_configs:
    - targets: ['my-app:8080']
```

Restart Prometheus for changes to take effect:

```bash
kubectl rollout restart deployment/prometheus -n monitoring
```

## Adding Grafana Data Sources

1. Port forward to Grafana
2. Go to Configuration > Data Sources
3. Add data source:
   - Type: Prometheus
   - URL: `http://prometheus:9090`
   - Name: Prometheus

For Loki logs:
   - Type: Loki
   - URL: `http://loki:3100`
   - Name: Loki

## Storage

All components with persistent storage use PVCs with `local-path` StorageClass:

- **Prometheus**: 10Gi (change via `prometheus.persistence.size`)
- **Grafana**: 2Gi (change via `grafana.persistence.size`)
- **Loki**: 5Gi (change via `loki.persistence.size`)
- **Alertmanager**: 1Gi (change via `alertmanager.persistence.size`)

To check storage usage:

```bash
kubectl get pvc -n monitoring
kubectl describe pvc prometheus-storage -n monitoring
```

## Resource Limits

All components have resource requests and limits optimized for edge K3s deployments. Adjust as needed in `values.yaml`:

- Prometheus: 256Mi min / 512Mi max
- Grafana: 128Mi min / 256Mi max
- Loki: 128Mi min / 256Mi max
- Node Exporter: 32Mi min / 64Mi max
- Promtail: 64Mi min / 128Mi max
- Blackbox Exporter: 64Mi min / 128Mi max
- Alertmanager: 64Mi min / 128Mi max

## Upgrading

```bash
helm upgrade monitoring ./monitoring-stack \
  -f custom-values.yaml \
  --namespace monitoring
```

## Uninstalling

```bash
helm uninstall monitoring --namespace monitoring
```

Note: This will remove all pods but NOT the PVCs. To remove storage as well:

```bash
kubectl delete pvc -n monitoring --all
```

## Differences from Docker Compose

1. **Network**: Kubernetes Services handle networking instead of Docker networks
2. **Config Files**: Converted to ConfigMaps
3. **Volumes**: Replaced with Persistent Volume Claims
4. **Replication**: Reduced to 1 pod per component (except DaemonSets)
5. **RBAC**: Added ServiceAccounts and ClusterRoles for Prometheus and Promtail

## Troubleshooting

### Pods not starting

```bash
kubectl describe pod <pod-name> -n monitoring
kubectl logs <pod-name> -n monitoring
```

### No storage available

Ensure `local-path` StorageClass exists:

```bash
kubectl get storageclass
```

### Prometheus not scraping metrics

Check the Prometheus targets page (`/targets`) and ServiceAccount RBAC permissions.

### Grafana can't connect to Prometheus

Verify the service DNS name. Within the pod, Prometheus should be reachable at `http://prometheus:9090`.

## Next Steps

1. Import Grafana dashboards (from Grafana.com or create custom ones)
2. Configure alerting rules
3. Set up external endpoints for Loki (optional, for log shipping)
4. Configure alertmanager routing (email, Slack, etc.)
