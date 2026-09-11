[//]: # (Confidential document - see ../../CONFIDENTIAL.md)

# Resource Management: Resource Quotas

*Part of the [Kubernetes Advanced Labs](../../README.md) · Module 1 · Previous: [Limit Ranges](../limit-ranges/README.md) · Next: [Cost Management: HPA](../../02-cost-management/scalability/hpa/README.md)*

## Overview

A ResourceQuota caps the total, aggregate resource consumption of a namespace — the counterpart to the per-object bounds set by a [LimitRange](../limit-ranges/README.md). Where a LimitRange asks "is this one Pod within bounds?", a ResourceQuota asks "does creating this object push the namespace as a whole over its budget?". This module shows a Deployment being scaled past both the CPU and the Pod-count budget of its namespace's quota.

## Objectives

By the end of this module, you will be able to:

- Explain what a ResourceQuota constrains: object counts and aggregate compute resource consumption per namespace.
- Apply a ResourceQuota and inspect its current usage against its hard limits.
- Observe what happens when scaling a Deployment would exceed a namespace's quota.

## Prerequisites

- Completion of [Limit Ranges](../limit-ranges/README.md).
- A running minikube cluster.

## Key concepts

### ResourceQuota

A `ResourceQuota` object provides constraints that limit aggregate resource consumption in a namespace. It can cap:

- The **number of objects** of a given type that may exist in the namespace (e.g. `pods: "3"`, or counts for Services, ConfigMaps, PVCs, etc.).
- The **total compute resources** (CPU, memory) requested or limited across every Pod in the namespace.

Unlike a LimitRange, a ResourceQuota doesn't inspect or default individual Pods — it simply refuses to admit a new object once satisfying it would exceed one of the quota's `hard` limits. This means every Pod in a namespace with a CPU/memory quota generally needs to declare requests (often via a LimitRange default) — otherwise Kubernetes cannot account for it against the quota.

## Lab

### Lab 1: Quotas vs. a scaled Deployment

**Goal:** apply a ResourceQuota capping the namespace at 1 CPU, 1 GiB of memory, and 3 Pods; deploy a Deployment within that budget; then scale it past the budget and observe the effect.

```bash
kubectl apply -f manifests/quotas.yaml
kubectl get quota
kubectl describe quota

kubectl apply -f manifests/deploy-quotas-example.yaml
kubectl get po
kubectl get quota
kubectl describe quota

kubectl scale deploy deploy-quotas-example --replicas=4
kubectl get deploy deploy-quotas-example
kubectl describe deploy deploy-quotas-example
kubectl describe rs
```

`deploy-quotas-example.yaml` starts at 2 replicas, each requesting `cpu: 500m` — exactly half of the namespace's 1-CPU quota, so both Pods are admitted. Scaling to 4 replicas asks for 2 full CPUs' worth of requests, which exceeds the quota's `hard.cpu: "1"` (and, independently, its `hard.pods: "3"`). The Deployment object itself still reports `replicas: 4`, but `kubectl describe rs` and the ReplicaSet's events show the extra Pods failing admission with a `forbidden: exceeded quota` error — the Deployment can ask for more Pods than the namespace is able to grant.

## Clean up

```bash
kubectl delete -f manifests/
```

## Further reading

- [Resource Quotas](https://kubernetes.io/docs/concepts/policy/resource-quotas/)
- [Configure Quotas for API Objects](https://kubernetes.io/docs/tasks/administer-cluster/quota-api-object/)

---
Previous: [Limit Ranges](../limit-ranges/README.md) · Next: [Cost Management: HPA](../../02-cost-management/scalability/hpa/README.md)
