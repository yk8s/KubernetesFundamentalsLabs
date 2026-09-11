[//]: # (Confidential document - see ../CONFIDENTIAL.md)

# Module 1: Core Concepts

*Part of the [Kubernetes Fundamentals Labs](../README.md) · Module 1 of 6 · Next: [Workloads](../02-workloads/README.md)*

## Overview

This module introduces the four objects you will use in almost every Kubernetes interaction: Namespaces, Pods, Labels/Selectors, and Services. Everything else in this course — Workloads, Storage, Configuration — is built on top of these primitives.

## Objectives

By the end of this module, you will be able to:

- Create and switch between Kubernetes Namespaces with `kubectl`.
- Create single- and multi-container Pods, and inspect them with `get`, `describe`, `logs`, and `exec`.
- Reach a Pod's exposed port through the API server proxy and through `kubectl port-forward`.
- Label objects and select them using both equality-based and set-based selectors.
- Create a ClusterIP Service and understand how it exposes a set of Pods inside the cluster.

## Prerequisites

- A running minikube cluster (see the [environment setup](../README.md#environment-setup) in the Part 1 overview).
- A terminal with `kubectl` configured against that cluster.

## Key concepts

### Namespaces

A Namespace is a logical partition of a Kubernetes cluster. Namespaces let you divide cluster resources between multiple teams, environments, or applications, and are the primary mechanism for scoping access control and resource quotas. Most Kubernetes objects (Pods, Services, Deployments, …) live inside a Namespace; a handful of cluster-wide objects (Nodes, PersistentVolumes, Namespaces themselves) do not.

### Pods

A Pod is the smallest deployable unit in Kubernetes — the atomic "unit of work" that the scheduler places on a Node. A Pod wraps one or more containers that share the same network namespace (so they can reach each other over `localhost`) and can share storage volumes. In practice, most Pods run a single container; multi-container Pods are used for tightly coupled helper patterns such as sidecars or init containers.

### Labels and selectors

Labels are key/value pairs attached to objects (Pods, Services, Nodes, …) that identify and group related resources — for example `app: nginx` or `environment: prod`. Selectors use those labels to find objects: an **equality-based** selector matches an exact key/value pair (`environment=prod`), while a **set-based** selector matches against a set of values (`environment in (prod, staging)`). Selectors are how Services find the Pods they route to, and how controllers like ReplicaSets know which Pods they own.

### Services

Pods are ephemeral — they can be rescheduled and get a new IP address at any time. A Service gives a stable, cluster-internal virtual IP and DNS name to a set of Pods selected by a label selector, and load-balances traffic across them via `kube-proxy`. This module covers the **ClusterIP** type, which is only reachable from inside the cluster; other Service types (NodePort, LoadBalancer) are covered in [Part 2: Services & Networking](../../part2/03-services-networking/services/README.md).

## Labs

### Lab 1: Namespaces

**Goal:** create a Namespace and switch your `kubectl` context to use it by default.

```bash
kubectl get namespaces
kubectl config get-contexts
kubectl create namespace dev
kubectl config set-context minikube --namespace=dev
kubectl config get-contexts
```

After this lab, every `kubectl` command you run (without an explicit `-n`) targets the `dev` Namespace.

### Lab 2: Pods

**Goal:** create single- and multi-container Pods, inspect them, and reach their exposed port from outside the Pod.

```bash
kubectl create -f manifests/pod-example.yaml
kubectl get po
kubectl get pod pod-example
kubectl describe pod pod-example
kubectl logs pod-example
kubectl exec -it pod-example -- sh

kubectl proxy
```

With `kubectl proxy` running in one terminal, open a second terminal and browse to:

- `http://127.0.0.1:8001/api/v1/namespaces/dev/pods/pod-example/proxy/`

> **Remote clusters only:** if your cluster runs on a remote host (e.g. a cloud VM) rather than locally, you'll need an SSH tunnel to reach `kubectl proxy` from your browser. Skip this step on a local cluster (minikube, kind, k3d).
>
> ```bash
> ssh -i XXX.pem -L 8001:localhost:8001 ubuntu@<remote-ip>
> ```

Alternatively, `kubectl port-forward` avoids the API server proxy entirely and maps a local port straight to the Pod:

```bash
kubectl port-forward --address 0.0.0.0 pod/pod-example 8888:80
```

- Local cluster: browse to `http://127.0.0.1:8888`
- Remote cluster: browse to `http://<public-ip>:8888`

Now repeat the exercise with a multi-container Pod, so you can see how `logs` and `exec` require you to name a container once there is more than one:

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

- `http://127.0.0.1:8001/api/v1/namespaces/dev/pods/multi-container-example/proxy/`

(Remote clusters only, same SSH tunnel as above: `ssh -i XXX.pem -L 8001:localhost:8001 ubuntu@<remote-ip>`)

### Lab 3: Labels and selectors

**Goal:** apply labels to running Pods, then filter Pods using both an equality selector and a shorthand selector.

```bash
kubectl label pod pod-example app=nginx environment=dev
kubectl label pod multi-container-example app=nginx environment=prod
kubectl get pods --show-labels
kubectl get pods --selector environment=prod
kubectl get pods -l app=nginx
```

### Lab 4: Services

**Goal:** create a ClusterIP Service and confirm it load-balances to the Pods matching its selector.

```bash
kubectl create -f manifests/service-clusterip.yaml
kubectl describe service clusterip

kubectl proxy
```

- `http://127.0.0.1:8001/api/v1/namespaces/dev/services/clusterip/proxy/`

(Remote clusters only: `ssh -i XXX.pem -L 8001:localhost:8001 ubuntu@<remote-ip>`)

## Clean up

```bash
kubectl delete -f manifests/
```

## Further reading

- [Namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
- [Pods](https://kubernetes.io/docs/concepts/workloads/pods/)
- [Labels and Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)
- [Service](https://kubernetes.io/docs/concepts/services-networking/service/)

---
Next: [Module 2: Workloads](../02-workloads/README.md)
