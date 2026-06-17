# Backup Idea Notes

Date: 2026-06-17

## Context
Planning migration from current Ansible + Docker setup to k3s.

## Questions discussed

### 1) Can a second server pull files via rsync from a PVC on k3s?
- Yes, but not directly from a PVC as if it were a normal host path.
- A PVC is mounted inside pods (or via node/CSI internals), so external hosts need an access path.

Suggested patterns:
- Run a backup pod (or sidecar/CronJob) that mounts the PVC and exposes SSH/rsync for pull-based backups.
- If storage supports RWX/network mount (e.g., NFS/CephFS), mount that backend on backup server.
- Avoid relying on node-internal volume paths as a primary backup strategy.
- Consider Kubernetes-native snapshots (e.g., CSI snapshots/Velero/Restic) for better consistency.

### 2) Can one PVC be mounted to two pods, with one read-only backup SSH pod?
- Yes, this is possible.
- The main constraint is PVC `accessModes`:
  - `ReadWriteOnce (RWO)`: usually two pods can mount only when scheduled on the same node.
  - `ReadWriteMany (RWX)`: can mount from multiple pods across nodes.
- Setting `readOnly: true` on backup pod only makes that pod read-only; app pod can still write.
- For application-consistent backups, prefer snapshot/quiesce workflow.

## Practical direction
- Keep current pull model by introducing a dedicated backup SSH pod that mounts the app PVC read-only.
- If using RWO storage, enforce scheduling so app pod and backup pod are on the same node.
- Long-term improvement: backup from snapshots/clones instead of live volume reads.
