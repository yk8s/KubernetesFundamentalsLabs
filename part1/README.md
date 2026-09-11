[//]: # (Confidential document - see CONFIDENTIAL.md)

# Kubernetes Fundamentals Labs

*Version 1.5.0*

## About this course

This is Part 1 of a two-part Kubernetes training program. It introduces the core building blocks of Kubernetes through short explanations followed by hands-on labs. Part 2, [Kubernetes Advanced Labs](../part2/README.md), builds on these fundamentals with resource management, cost management, networking, and security topics.

No prior Kubernetes experience is assumed, but familiarity with containers (Docker) and basic command-line usage will help.

## Training program

1. **Introduction to Kubernetes**
   - Project overview
   - Key concepts
2. **Architecture overview**
   - Control plane
   - Node
3. **Kubernetes networking**
   - Container Network Interface (CNI)
   - CNI plugins
4. **Concepts and resources** — see [Module 1: Core Concepts](01-core/README.md), [Module 2: Workloads](02-workloads/README.md), [Module 3: Storage](03-storage/README.md), and [Module 4: Configuration](04-configuration/README.md)
   - Core objects: Namespaces, Pods, Labels, Selectors, Services
   - Workloads: ReplicaSet, Deployment, DaemonSet, StatefulSet, Job, CronJob
   - Storage: Volumes, Persistent Volumes, Persistent Volume Claims, dynamic/static provisioning, Storage Classes
   - Configuration: ConfigMaps, Secrets
5. **Package management** — see [Module 5: Helm](05-helm/README.md)
6. **Mini project (sample application)** — see [Module 6: Examples](06-examples/wordpress/README.md) and the [Mini Project](#mini-project) section below
   - Architecture review
   - Database
   - Application server

## Modules

| # | Module | Topics | Labs |
|---|--------|--------|------|
| 1 | [Core Concepts](01-core/README.md) | Namespaces, Pods, Labels & Selectors, Services | 4 |
| 2 | [Workloads](02-workloads/README.md) | ReplicaSet, Deployment, DaemonSet, StatefulSet, Job, CronJob | 6 |
| 3 | [Storage](03-storage/README.md) | Volumes, Persistent Volumes, Persistent Volume Claims, Storage Classes | 2 |
| 4 | [Configuration](04-configuration/README.md) | ConfigMaps, Secrets | 2 |
| 5 | [Helm](05-helm/README.md) | Chart lifecycle, chart authoring, templating | 9 |
| 6 | [Examples: WordPress](06-examples/wordpress/README.md) | Multi-tier application deployment | 1 |

Work through the modules in order — each one assumes the concepts and objects created in the previous module (or reminds you to clean them up first).

## Environment setup

These labs use [minikube](https://minikube.sigs.k8s.io/docs/start/), a tool that runs a single-node Kubernetes cluster locally, so you can learn and experiment without needing a cloud account.

**Prerequisites**

- 2 CPUs or more
- 2 GB of free memory
- 20 GB of free disk space
- An internet connection
- A container or virtual machine manager, such as Docker, Hyper-V, or VirtualBox

Refer to the [minikube documentation](https://minikube.sigs.k8s.io/docs/start/) for installation instructions specific to your operating system.

Once minikube is installed, start your cluster and confirm it is healthy:

```bash
minikube start --driver=docker --cni=cilium
kubectl get pods -A
kubectl get namespaces
kubectl config get-contexts
```

If you are working from a remote lab environment, download the lab materials with:

```bash
scp -i key.pem -r ubuntu@<lab-host>:/home/ubuntu/KubernetesFundamentalsLabs-v1.5.0/ "$(pwd)"
```

Once your cluster is up and running, head to [Module 1: Core Concepts](01-core/README.md) to get started.

## Mini project

The `project/` directory contains the manifests for a self-directed capstone exercise, split into two checkpoints that build on the skills covered in Modules 1–4:

- **`project/sprint2/`** — a Secret consumed by a Pod, a StatefulSet backed by a Storage Class, and a ClusterIP Service.
- **`project/sprint3/`** — a Deployment with a rolling update strategy, a PersistentVolumeClaim shared between a reader and writer workload, and a NodePort Service.

There is no separate walkthrough for this project: use what you learned in the Core Concepts, Workloads, Storage, and Configuration modules to deploy, verify, and clean up each sprint's manifests on your own cluster.

## Conventions used in these labs

- Commands are shown in shell code blocks and are meant to be run with `kubectl` (or `helm`, where noted) against your local minikube cluster.
- Placeholders you need to replace are wrapped in angle brackets, e.g. `<pod-template-hash>`.
- Every module ends with a **Clean up** section — run it before moving to the next module to avoid naming collisions and leftover resources.

Ready? Start with [Module 1: Core Concepts](01-core/README.md).
