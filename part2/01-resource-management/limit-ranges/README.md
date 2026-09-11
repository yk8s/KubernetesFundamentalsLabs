[//]: # (Confidential document - see ../../CONFIDENTIAL.md)

# Resource Management: Limit Ranges

*Part of the [Kubernetes Advanced Labs](../../README.md) · Module 1 · Previous: [QoS](../qos/README.md) · Next: [Quotas](../quotas/README.md)*

## Overview

A LimitRange is a namespace-scoped policy that constrains — and can default — the resource requests and limits of the objects created in that namespace. Where the [QoS module](../qos/README.md) showed how a single Pod's own requests/limits determine its class, this module shows how a cluster administrator can enforce sane defaults and bounds across an entire namespace, without relying on every developer to set them correctly by hand.

## Objectives

By the end of this module, you will be able to:

- Explain what a LimitRange can enforce: default requests/limits, minimum/maximum bounds, and request-to-limit ratios.
- Apply a LimitRange that injects default requests and limits into Pods that don't specify their own.
- Apply a LimitRange that additionally enforces minimum and maximum bounds, and observe what happens to a Pod that violates them.

## Prerequisites

- Completion of [QoS](../qos/README.md) (this module assumes you understand requests and limits).
- A running minikube cluster.

## Key concepts

### What a LimitRange can do

A LimitRange is enforced in any namespace where a `LimitRange` object exists. Depending on how it's configured, it can:

- Enforce a **minimum and maximum** for compute resource usage per Pod or Container in the namespace.
- Enforce a **minimum and maximum storage request** per PersistentVolumeClaim in the namespace.
- Enforce a **ratio** between request and limit for a resource (e.g. limit must be no more than 2× the request).
- Set **default** request/limit values for compute resources, automatically injected into Containers that don't specify their own at creation time.

Unlike a ResourceQuota (covered in the [next module](../quotas/README.md)), a LimitRange validates and mutates **individual objects** as they're created — it has no concept of an aggregate, namespace-wide total.

## Labs

### Lab 1: Default request and default limit

**Goal:** apply a LimitRange that sets default CPU/memory requests and limits, then confirm a Pod created without its own `resources` block inherits them.

```bash
kubectl apply -f manifests/container-limit-range-example1.yaml
kubectl describe limitrange/container-limit-range-example1
kubectl apply -f manifests/pod-example1.yaml
kubectl get pod pod-example1 --output=custom-columns=NAME:.metadata.name,CPU-R:.spec.containers[*].resources.requests.cpu,MEMORY-R:.spec.containers[*].resources.requests.memory,CPU-L:.spec.containers[*].resources.limits.cpu,MEMORY-L:.spec.containers[*].resources.limits.memory
kubectl delete limitrange/container-limit-range-example1
```

Even though `pod-example1.yaml` doesn't declare a `resources` block itself, the `custom-columns` output shows it was assigned the LimitRange's `defaultRequest` and `default` values automatically.

### Lab 2: Minimum, maximum, default request, and default limit

**Goal:** apply a stricter LimitRange that adds minimum and maximum bounds on top of the defaults, and confirm a Pod is still admitted as long as it fits within them.

```bash
kubectl apply -f manifests/container-limit-range-example2.yaml
kubectl describe limitrange/container-limit-range-example2
kubectl apply -f manifests/pod-example2.yaml
kubectl get pod pod-example2 --output=custom-columns=NAME:.metadata.name,CPU-R:.spec.containers[*].resources.requests.cpu,MEMORY-R:.spec.containers[*].resources.requests.memory,CPU-L:.spec.containers[*].resources.limits.cpu,MEMORY-L:.spec.containers[*].resources.limits.memory
```

**Try it yourself:** edit `pod-example2.yaml` to request more than the LimitRange's `max`, re-apply it, and observe the admission error Kubernetes returns instead of creating the Pod.

## Clean up

```bash
kubectl delete -f manifests/
```

## Further reading

- [Limit Ranges](https://kubernetes.io/docs/concepts/policy/limit-range/)
- [Configure Default Memory Requests and Limits for a Namespace](https://kubernetes.io/docs/tasks/administer-cluster/manage-resources/memory-default-namespace/)
- [Configure Minimum and Maximum Memory Constraints for a Namespace](https://kubernetes.io/docs/tasks/administer-cluster/manage-resources/memory-constraint-namespace/)

---
Previous: [QoS](../qos/README.md) · Next: [Quotas](../quotas/README.md)
