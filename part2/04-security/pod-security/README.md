[//]: # (Confidential document - see ../../CONFIDENTIAL.md)

# Security: Pod Security Context

*Part of the [Kubernetes Advanced Labs](../../README.md) · Module 4 · Previous: [Services & Networking: Ingress](../../03-services-networking/ingress/README.md) · Next: [Network Security](../network-security/README.md)*

## Overview

This is the first of five security modules, which build on each other roughly in the order the [Cloud Native Security 4Cs](https://kubernetes.io/docs/concepts/security/overview/) model suggests: **Container** (this module), then **Cluster** networking ([Network Security](../network-security/README.md)) and cluster access control ([RBAC](../rbac/README.md)), then policy enforcement across the cluster ([Kyverno](../kyverno/README.md)), and finally scanning everything for known issues ([Trivy](../trivy/README.md)). This module starts at the container level: constraining what a container's processes are allowed to do on the host they run on, via a security context.

## Objectives

By the end of this module, you will be able to:

- Explain what a security context controls, and the precedence between Pod-level and container-level settings.
- Set `runAsUser`, `runAsGroup`, and `fsGroup` at the Pod level, and confirm their effect on process and file ownership.
- Override a Pod-level `runAsUser` at the container level.

## Prerequisites

- Completion of [Part 1: Core Concepts](../../../part1/01-core/README.md) and [Configuration](../../../part1/04-configuration/README.md).
- A running minikube cluster.

## Key concepts

### Security contexts

A security context defines privilege and access-control settings for a Pod or a Container. `PodSecurityContext` (set under `spec.securityContext`) holds Pod-level attributes and defaults shared by every container in the Pod; a container's own `securityContext` (under `spec.containers[].securityContext`) can override those defaults for that container specifically. When both are set for the same field, **the container-level value wins**.

Three fields matter most for this lab:

- `runAsUser` — the UID the container's process runs as.
- `runAsGroup` — the primary GID the container's process runs as. If omitted, the process's group remains GID `0` (root), meaning it can access files owned by the root group with group permissions — usually not what you want.
- `fsGroup` — a supplementary GID applied to mounted volumes: files created in those volumes are owned by this group, regardless of which user created them.

## Labs

### Lab 1: Security context at the Pod level

**Goal:** run a Pod with `runAsUser: 1000`, `runAsGroup: 3000`, and `fsGroup: 2000`, and confirm each setting's effect from inside the container.

```bash
kubectl apply -f manifests/pod-security-context-example.yaml
kubectl get pod pod-security-context-example
kubectl exec -it pod-security-context-example -- sh
```

Inside the container:

```sh
id                          # uid=1000, gid=3000, and supplementary group 2000 (fsGroup)
ps                          # processes run as user 1000 (runAsUser)
cd /data/demo
ls -l                       # the mounted volume's group is 2000 (fsGroup)
echo hello > testfile
ls -l                       # testfile is also owned by group 2000
exit
```

```bash
kubectl delete po pod-security-context-example
```

> If `runAsGroup` were omitted, the process's group would remain `0` (root) instead of `3000`, letting it interact with any file that grants access to the root group.

### Lab 2: Security context at the container level

**Goal:** confirm that a container-level `runAsUser` overrides the Pod-level value.

```bash
kubectl apply -f manifests/container-security-context-example.yaml
kubectl get pod container-security-context-example
kubectl exec -it container-security-context-example -- sh
```

Inside the container:

```sh
ps aux    # the process runs as user 2000, not the Pod-level 1000
exit
```

```bash
kubectl delete po container-security-context-example
```

The Pod sets `runAsUser: 1000`, but the container overrides it with `runAsUser: 2000` — confirming that container-level settings take precedence over Pod-level ones.

## Clean up

```bash
kubectl delete -f manifests/
```

## Further reading

- [Configure a Security Context for a Pod or Container](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)
- [Overview of Cloud Native Security](https://kubernetes.io/docs/concepts/security/overview/)
- [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/) — cluster-wide baselines that build on the same fields covered here, enforced later in [Kyverno](../kyverno/README.md)

---
Previous: [Services & Networking: Ingress](../../03-services-networking/ingress/README.md) · Next: [Network Security](../network-security/README.md)
