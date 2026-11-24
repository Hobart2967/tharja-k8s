# AI backend services

This system release deploys two internal-only CPU services into the `sys-ai` namespace:

- **Speaches**: OpenAI-compatible speech API for faster-whisper STT and Piper/Kokoro TTS.
- **Ollama**: CPU inference endpoint for small utility models (for example, OpenCode compaction).

Both Services are ClusterIP-only. No public IngressRoute or DNS record is created.

## Deploy

From the repository's `k8s` directory:

```sh
helmfile -f system/sys-ai/helmfile.yaml sync
```

Or include it through the normal top-level `helmfile.yaml` (already wired into `system/helmfile.yaml`).

## Endpoints

Inside the cluster:

- Speaches: `http://speaches.sys-ai.svc.cluster.local:8000/v1`
- Ollama: `http://ollama.sys-ai.svc.cluster.local:11434`

For temporary access from a workstation with Kubernetes API access:

```sh
kubectl -n sys-ai port-forward svc/ollama 11434:11434
kubectl -n sys-ai port-forward svc/speaches 8000:8000
```

Ollama model weights are stored in its PVC. Pull a model after port-forwarding, for example:

```sh
ollama pull qwen2.5:3b-instruct-q4_K_M
```

Choose the actual model tag to match the client and its context/output requirements.

## Resource sizing

The namespace LimitRange permits up to 8 CPU and 16 GiB per container. Current per-container limits are 4 CPU / 4 GiB for Speaches and 4 CPU / 6 GiB for Ollama. These are ceilings, not guaranteed performance targets. CPU inference latency depends heavily on the selected models and concurrent requests.

Speaches downloads model files on demand into its Hugging Face cache PVC (10 GiB). Ollama stores pulled models in a separate 20 GiB PVC. Adjust both capacities to match the models you intend to keep.

## Network access

The Services are intentionally not exposed publicly. ClusterIP addresses are reachable only from workloads with cluster networking. VPN-connected clients outside the cluster will need a private ingress/reverse proxy or another explicitly routed access path; a ClusterIP alone is not routable over the Fritz!Box VPN.
