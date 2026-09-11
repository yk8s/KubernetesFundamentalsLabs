[//]: # (Confidential document - see ../../CONFIDENTIAL.md)

# Resource Management: Quality of Service (QoS)

*Part of the [Kubernetes Advanced Labs](../../README.md) · Module 1 · Next: [Limit Ranges](../limit-ranges/README.md)*

## Overview

Kubernetes assigns every Pod to one of three Quality of Service (QoS) classes, purely as a function of the resource `requests` and `limits` set on its containers. This classification isn't just informational — the scheduler and kubelet use it to decide which Pods to evict first when a Node runs low on resources. Understanding QoS classes is the foundation for the Limit Ranges and Quotas modules that follow, since both are ultimately about shaping requests and limits at the namespace level.

## Objectives

By the end of this module, you will be able to:

- Explain the difference between a resource **request** and a resource **limit**.
- Determine which QoS class (`Guaranteed`, `Burstable`, or `BestEffort`) a Pod will be assigned, from its container resource specs.
- Read a Pod's assigned QoS class with `kubectl`.
- Explain how QoS class affects eviction order under Node resource pressure.

## Prerequisites

- Completion of [Part 1: Workloads](../../../part1/02-workloads/README.md) (Pods and Deployments).
- A running minikube cluster.

## Key concepts

### Requests vs. limits

A container's resource **request** is what the scheduler guarantees it — the scheduler only places a Pod on a Node that has at least that much unallocated CPU/memory. A **limit** is a hard ceiling: the kubelet throttles CPU usage above the limit, and kills (OOM-kills) a container that exceeds its memory limit. A container may have a request without a limit, a limit without a request (in which case the request defaults to the limit), or both.

### QoS classes

Kubernetes derives a Pod's QoS class from the requests and limits of **all** its containers, using these rules:

- **Guaranteed** — every container has both a memory and a CPU limit, and for every container the request equals the limit for each resource.
- **Burstable** — at least one container has a memory or CPU request or limit, but the Pod doesn't meet the criteria for `Guaranteed`.
- **BestEffort** — no container has any memory or CPU request or limit set.

Under Node resource pressure, Kubernetes evicts Pods in this order: `BestEffort` first, then `Burstable`, and `Guaranteed` last (and only if it is itself exceeding its requests). In other words, the more precisely a Pod's resource needs are declared, the more protected it is from eviction.

## Lab

### Lab 1: Observe a Guaranteed-class Pod

**Goal:** apply a Pod whose containers request and limit the exact same CPU and memory, and confirm Kubernetes classifies it as `Guaranteed`.

```bash
kubectl apply -f manifests/pod-qos-example.yaml
kubectl get pod pod-qos-example --output=jsonpath='{.status.qosClass}'
kubectl describe po pod-qos-example
```

`manifests/pod-qos-example.yaml` sets `requests` equal to `limits` for both `cpu` and `memory`, so it lands in the `Guaranteed` class.

**Try it yourself:** to see the other two classes, edit a copy of the manifest:

- Remove the `limits` block (keep only `requests`) → the Pod becomes `Burstable`.
- Remove `resources` entirely → the Pod becomes `BestEffort`.

Re-run the `kubectl get ... jsonpath='{.status.qosClass}'` command after each change to confirm the class Kubernetes assigns.

## Clean up

```bash
kubectl delete -f manifests/pod-qos-example.yaml
```

## Further reading

- [Configure Quality of Service for Pods](https://kubernetes.io/docs/tasks/configure-pod-container/quality-service-pod/)
- [Resource Management for Pods and Containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
- [Node-pressure Eviction](https://kubernetes.io/docs/concepts/scheduling-eviction/node-pressure-eviction/)

---
Next: [Limit Ranges](../limit-ranges/README.md)
