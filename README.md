# OpenClaw Helm Chart

This chart deploys [OpenClaw Gateway](https://github.com/openclaw/openclaw) on a Kubernetes cluster.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (e.g., Longhorn, GCP PD, etc.)

## Quick Start

```console
helm repo add openclaw https://elaugaste.github.io/openclaw-helm/
helm repo update
helm install openclaw openclaw/openclaw
```

## Configuration

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Image repository | `ghcr.io/elaugaste/openclaw` |
| `image.tag` | Image tag | `latest` |
| `service.port` | Service port | `18789` |
| `ingress.enabled` | Enable ingress | `false` |
| `persistence.config.enabled` | Enable persistence for `~/.openclaw` | `true` |
| `persistence.config.size` | Persistence volume size | `5Gi` |
| `persistence.config.storageClass` | StorageClass for the volume | `""` |
| `auth.enabled` | Enable Gateway authentication | `false` |
| `configFiles.openclawJson` | Content of `openclaw.json` | See `values.yaml` |
| `configFiles.heartbeat` | Content of `HEARTBEAT.md` | See `values.yaml` |

## Configuration Files

The chart manages two main configuration files via `ConfigMap`:
1. `~/.openclaw/openclaw.json`: Main application configuration.
2. `~/.openclaw/workspace/HEARTBEAT.md`: Heartbeat agent settings.

These files are **copied** from the ConfigMap to the persistent volume on every pod start. This ensures that:
- You can update configurations via `values.yaml` and `helm upgrade`.
- The application has full **write access** to these files at runtime.

## Authentication

To enable authentication, set `auth.enabled: true`. If `auth.token` is empty, a random 64-character token will be generated and stored in a Kubernetes Secret (`openclaw-auth`).

```yaml
auth:
  enabled: true
```

The token is injected into the container as `OPENCLAW_GATEWAY_TOKEN`.

## Ingress & WebSocket

OpenClaw Gateway uses port `18789` for both HTTP and WebSocket traffic. For stable WebSocket connections, increase proxy timeouts in your Ingress controller:

```yaml
ingress:
  enabled: true
  className: nginx
  annotations:
    nginx.ingress.kubernetes.io/proxy-read-timeout: "3600"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "3600"
  hosts:
    - host: openclaw.local
      paths:
        - path: /
          pathType: ImplementationSpecific
```

## Development & Image Build

A `Makefile` is provided to build and push the Docker image (optimized for `linux/amd64`):

```bash
# Build the image with additional APT packages
make build OPENCLAW_DOCKER_APT_PACKAGES="ffmpeg curl"

# Push to registry
make push REGISTRY=ghcr.io/elaugaste
```

## Security

- The pod runs as a non-root user (`uid: 1000`).
- Config files mounted from Secrets/ConfigMaps have `defaultMode: 0600`.
- An `initContainer` is used to ensure correct volume permissions (`1000:1000`).