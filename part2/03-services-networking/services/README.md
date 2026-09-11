[//]: # (Confidential document - see ../../CONFIDENTIAL.md)

# Services & Networking: Services

*Part of the [Kubernetes Advanced Labs](../../README.md) · Module 3 · Previous: [Cost Management: KEDA](../../02-cost-management/scalability/keda/README.md) · Next: [Ingress](../ingress/README.md)*

## Overview

A Service exposes a set of Pods as a single, stable network endpoint. This module revisits Pods, Labels, and Selectors as a quick refresher (see [Part 1: Core Concepts](../../../part1/01-core/README.md) for the full treatment), then focuses on the three Service types you're most likely to use in practice: `ClusterIP`, `NodePort`, and `LoadBalancer`. Understanding the differences between them is a prerequisite for [Ingress](../ingress/README.md), which builds on top of Services to route external HTTP(S) traffic.

## Objectives

By the end of this module, you will be able to:

- Create Pods, inspect them, and reach an exposed port through the API server proxy.
- Label Pods and select them using both direct labels and selectors.
- Explain the difference between `ClusterIP`, `NodePort`, and `LoadBalancer` Services, and when to use each.
- Create all three Service types and reach each one from outside the Pods it targets.

## Prerequisites

- Completion of [Part 1: Core Concepts](../../../part1/01-core/README.md) and [Cost Management: KEDA](../../02-cost-management/scalability/keda/README.md).
- A running minikube cluster.

## Key concepts

### Services

A Service is a stable way to expose an application running as one or more Pods, without requiring the application itself to know about Kubernetes' service discovery mechanism. Whether the Pods behind it are cloud-native from the start or an older application you've simply containerized, a Service gives clients on the network a consistent name and address to reach them at — decoupling "what talks to what" from the constantly changing set of individual Pod IPs.

### Service types

- **ClusterIP** (the default) assigns a stable virtual IP reachable only from inside the cluster. Use it for internal-only communication between workloads.
- **NodePort** additionally opens a fixed port (in the `30000–32767` range) on every Node in the cluster, forwarding it to the Service. Use it for simple external access without needing a cloud load balancer — common in on-prem or local clusters.
- **LoadBalancer** additionally provisions an external load balancer (via your cloud provider, or a tool like MetalLB on bare-metal/local clusters) with its own public or routable IP. Use it as the standard way to expose a Service directly to the internet in a cloud environment.

Each type is a strict superset of the previous one: a `LoadBalancer` Service still gets a ClusterIP and a NodePort under the hood.

## Labs

### Lab 1: Pods

**Goal:** create single- and multi-container Pods and practice `get`, `describe`, `logs`, and `exec`.

```bash
kubectl create -f manifests/pod-example.yaml
kubectl get po
kubectl get pod pod-example
kubectl describe pod pod-example
kubectl logs pod-example
kubectl exec -it pod-example -- sh

kubectl proxy
```

- `http://127.0.0.1:8001/api/v1/namespaces/default/pods/pod-example/proxy/`

> **Remote clusters only:** tunnel port 8001 over SSH before browsing to the URL above; skip this on a local cluster (minikube, kind, k3d).
>
> ```bash
> ssh -i XXX.pem -L 8001:localhost:8001 ubuntu@<remote-ip>
> ```

```bash
kubectl create -f manifests/pod-multi-container-example.yaml
kubectl get po
kubectl describe po multi-container-example
kubectl logs multi-container-example
kubectl logs -c nginx multi-container-example
kubectl logs -c content multi-container-example
kubectl exec -it multi-container-example -- sh
kubectl exec -it -c nginx multi-container-example -- sh

kubectl proxy
```

- `http://127.0.0.1:8001/api/v1/namespaces/default/pods/multi-container-example/proxy/`

### Lab 2: Labels and selectors

**Goal:** label the Pods created above, then filter them by label.

```bash
kubectl label pod pod-example app=nginx environment=dev
kubectl label pod multi-container-example app=nginx environment=prod
kubectl get pods --show-labels
kubectl get pods --selector environment=prod
kubectl get pods -l app=nginx
```

### Lab 3: ClusterIP Service

**Goal:** expose the labeled Pods through a ClusterIP Service and confirm it's only reachable from inside the cluster.

```bash
kubectl create -f manifests/service-clusterip.yaml
kubectl describe service clusterip
kubectl proxy
```

- `http://127.0.0.1:8001/api/v1/namespaces/default/services/clusterip/proxy/`

(Remote clusters only: `ssh -i XXX.pem -L 8001:localhost:8001 ubuntu@<remote-ip>`)

### Lab 4: NodePort and LoadBalancer Services

**Goal:** expose the same Pods with a NodePort and a LoadBalancer Service, and compare how each is reached.

```bash
kubectl create -f manifests/service-nodeport.yaml
kubectl describe service nodeport
minikube service nodeport --url
```

`minikube service --url` prints the URL for the Node's IP and the Service's assigned `nodePort` (`32410` in this manifest) — open it in your browser to confirm you reach the same Pods as before, now without needing `kubectl proxy`.

```bash
kubectl create -f manifests/service-loadbalancer.yaml
kubectl get service loadbalancer --watch
```

On a cloud cluster, a `LoadBalancer` Service's `EXTERNAL-IP` is populated automatically by the cloud provider. minikube has no cloud provider to do this, so `EXTERNAL-IP` stays `<pending>` unless you run `minikube tunnel` in a separate terminal (which simulates one) — or simply use `minikube service loadbalancer --url` as you did for the NodePort Service above.

## Clean up

```bash
kubectl delete -f manifests/
```

## Further reading

- [Service](https://kubernetes.io/docs/concepts/services-networking/service/)
- [Connecting Applications with Services](https://kubernetes.io/docs/tutorials/services/connect-applications-service/)
- [minikube: accessing apps](https://minikube.sigs.k8s.io/docs/handbook/accessing/)

---
Previous: [Cost Management: KEDA](../../02-cost-management/scalability/keda/README.md) · Next: [Ingress](../ingress/README.md)
