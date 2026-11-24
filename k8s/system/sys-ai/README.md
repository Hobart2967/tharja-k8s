# AI backend services

This system release deploys two CPU-backed APIs into the `sys-ai` namespace:

- **Speaches**: OpenAI-compatible speech API for speech-to-text and text-to-speech.
- **Ollama**: CPU inference endpoint for small utility models (for example, OpenCode compaction).

## Network exposure and access control

Both Services use `type: LoadBalancer`. K3s ServiceLB (Klipper) publishes the ports on the node address; no MetalLB installation or public IngressRoute is required.

The configured access range is the home LAN/VPN subnet `192.168.178.0/24`:

- Speaches: `http://<node-lan-ip>:8000/v1`
- Ollama: `http://<node-lan-ip>:11434`

Two Kubernetes controls are configured:

- `loadBalancerSourceRanges` restricts allowed source addresses at the Service level.
- A pod-selecting NetworkPolicy allows ingress only from the configured CIDRs.
- `externalTrafficPolicy: Local` requests preservation of the original client source IP.

The repository's Ansible K3s installation does not pass `--disable-network-policy`, so K3s's built-in network-policy controller should be active. Verify on the cluster:

```sh
kubectl get pods -n kube-system | grep -E 'kube-router|netpol'
kubectl get networkpolicy -n sys-ai
kubectl -n sys-ai get svc speaches ollama
```

**Do not consider the endpoints protected until the checks below pass.** NetworkPolicy enforcement depends on the K3s network-policy controller being active and the actual source IP reaching the pod matching `192.168.178.0/24`. VPN routing or NAT may change the source address; if so, determine the observed source CIDR and configure that exact trusted range.

Do not create Fritz!Box port forwards for TCP 8000 or 11434. Test both endpoints from a VPN client and separately from an external internet connection; the external test must fail. If it succeeds, disable the Services or stop the release until the network path is secured.

## Deploy

From the repository's `k8s` directory:

```sh
helmfile -f system/sys-ai/helmfile.yaml sync
```

Or include it through the normal top-level system Helmfile.

## Resource sizing

The namespace resource ceiling is configured separately. Current per-container limits are 4 CPU / 4 GiB for Speaches and 4 CPU / 6 GiB for Ollama. These are upper bounds, not performance guarantees. CPU inference latency and peak memory depend on the selected models and concurrency.

Speaches caches downloaded models in its PVC (10 GiB); Ollama stores model weights in its PVC (20 GiB). Both PVCs explicitly use `local-path-projects-retained`.

## Initial model setup

After deployment, pull an Ollama model through the node endpoint, for example:

```sh
ollama pull qwen2.5:3b-instruct-q4_K_M
```

Choose a model tag compatible with the client's context and output requirements.
