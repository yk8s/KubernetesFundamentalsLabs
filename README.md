[//]: # (Confidential document - see part1/CONFIDENTIAL.md and part2/CONFIDENTIAL.md)

# Kubernetes Fundamentals & Advanced Labs

*Version 1.5.0*

A two-part, hands-on Kubernetes training course. Each module pairs a short conceptual explanation with a lab you run yourself against a real (local) cluster — there are no slides to sit through, just `kubectl`, `helm`, and a terminal.

## Course structure

The course is split into two self-contained parts:

| Part | Focus | Start here |
|---|---|---|
| **[Part 1 — Fundamentals](part1/README.md)** | Core objects, Workloads, Storage, Configuration, Helm, and a multi-tier example application | [part1/README.md](part1/README.md) |
| **[Part 2 — Advanced](part2/README.md)** | Resource management, cost management, Services & networking, and Security | [part2/README.md](part2/README.md) |

Part 2 assumes the concepts from Part 1, so work through Part 1 first if you're new to Kubernetes. If you already know the fundamentals, you can jump straight into Part 2.

### Part 1 — Fundamentals

| # | Module | Topics |
|---|---|---|
| 1 | [Core Concepts](part1/01-core/README.md) | Namespaces, Pods, Labels & Selectors, Services |
| 2 | [Workloads](part1/02-workloads/README.md) | ReplicaSet, Deployment, DaemonSet, StatefulSet, Job, CronJob |
| 3 | [Storage](part1/03-storage/README.md) | Volumes, Persistent Volumes, Persistent Volume Claims, Storage Classes |
| 4 | [Configuration](part1/04-configuration/README.md) | ConfigMaps, Secrets |
| 5 | [Helm](part1/05-helm/README.md) | Chart lifecycle, chart authoring, templating |
| 6 | [Examples: WordPress](part1/06-examples/wordpress/README.md) | Multi-tier application deployment |

Part 1 also includes a self-directed [mini project](part1/README.md#mini-project) that combines everything from Modules 1–4.

### Part 2 — Advanced

| # | Module | Topics |
|---|---|---|
| 1 | Resource Management | [QoS](part2/01-resource-management/qos/README.md), [Limit Ranges](part2/01-resource-management/limit-ranges/README.md), [Quotas](part2/01-resource-management/quotas/README.md) |
| 2 | Cost Management → Scalability | [HPA](part2/02-cost-management/scalability/hpa/README.md), [KEDA](part2/02-cost-management/scalability/keda/README.md) |
| 3 | Services & Networking | [Services](part2/03-services-networking/services/README.md), [Ingress](part2/03-services-networking/ingress/README.md) |
| 4 | Security | [Pod Security](part2/04-security/pod-security/README.md), [Network Security](part2/04-security/network-security/README.md), [RBAC](part2/04-security/rbac/README.md), [Kyverno](part2/04-security/kyverno/README.md), [Trivy](part2/04-security/trivy/README.md) |

## Prerequisites

Both parts run on [minikube](https://minikube.sigs.k8s.io/docs/start/), a local single-node Kubernetes cluster, so you don't need a cloud account to follow along.

- 2 CPUs or more
- 2 GB of free memory
- 20 GB of free disk space
- An internet connection
- A container or virtual machine manager, such as Docker, Hyper-V, or VirtualBox

Full environment setup steps (starting minikube, verifying `kubectl` access, downloading the lab materials) are in the [Part 1](part1/README.md#environment-setup) and [Part 2](part2/README.md#environment-setup) READMEs — the same steps, so set it up once and use it for both parts.

## How to use these labs

- Work through modules in the order listed above — each one builds on objects or concepts from the previous one.
- Every module README follows the same structure: **Overview**, **Objectives**, **Prerequisites**, **Key Concepts**, **Labs**, **Clean up**, and **Further Reading**, plus links to the previous/next module.
- Each module's **Clean up** section removes everything it created — run it before moving on, to avoid naming collisions with later labs.
- Kubernetes manifests for each module's labs live in that module's own `manifests/` directory, referenced directly from its README.

## Confidentiality

This material is for internal use only — see [`part1/CONFIDENTIAL.md`](part1/CONFIDENTIAL.md) and [`part2/CONFIDENTIAL.md`](part2/CONFIDENTIAL.md).

---

Ready? Start with [Part 1 — Fundamentals](part1/README.md).
