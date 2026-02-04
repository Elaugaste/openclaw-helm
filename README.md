# OpenClaw Helm Chart

This chart deploys OpenClaw Gateway on a Kubernetes cluster.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (if persistence is enabled)

## Installing the Chart

To install the chart with the release name `openclaw`:

```console
helm install openclaw .
```

## Configuration

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Image repository | `ghcr.io/elaugaste/openclaw` |
| `image.tag` | Image tag | `latest` |
| `service.port` | Service port | `18789` |
| `ingress.enabled` | Enable ingress | `false` |
| `persistence.config.enabled` | Enable persistence for ~/.openclaw | `true` |
| `persistence.config.size` | Persistence size | `1Gi` |
| `auth.enabled` | Enable HTTP auth | `false` |
| `env` | Environment variables | See `values.yaml` |

## Authentication

To enable authentication, set `auth.enabled` to `true`. If `auth.token` is not provided, a random 64-character token will be generated automatically.

```yaml
auth:
  enabled: true
```

Or provide a custom token:

```yaml
auth:
  enabled: true
  existingSecret: "my-k8s-secret"
  secretKey: "token-key"
```

## Ingress Example

To enable ingress with a custom host:

```yaml
ingress:
  enabled: true
  className: nginx
  annotations:
    nginx.ingress.kubernetes.io/proxy-read-timeout: "3600"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "3600"
  hosts:
    - host: openclaw.example.com
      paths:
        - path: /
          pathType: ImplementationSpecific
```

## WebSocket Support

OpenClaw Gateway uses a single multiplexed port (18789) for both HTTP and WebSocket traffic. When using an Ingress controller, ensure that:
1. Proxy timeouts are increased (e.g., to 1 hour) to prevent long-lived WebSocket connections from dropping.
2. The Ingress controller is configured to handle the `Upgrade` and `Connection` headers (most modern controllers do this automatically).

## Persistence

OpenClaw stores its configuration and workspace in `/home/node/.openclaw`. By default, this chart creates a PersistentVolumeClaim to persist this data.

## Security

The pod runs as a non-root user (uid 1000) for security hardening.
