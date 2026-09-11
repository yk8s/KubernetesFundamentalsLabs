[//]: # (Confidential document - see CONFIDENTIAL.md)

# Kubernetes Advanced Labs

*Version 1.5.0*

## About this course

This is Part 2 of a two-part Kubernetes training program. It assumes you are comfortable with the core objects and workloads covered in Part 1, [Kubernetes Fundamentals Labs](../part1/README.md), and builds on them with resource management, cost management, networking, and security topics that matter once you're running real workloads on shared clusters.

If you completed Part 1 on the same cluster, you can jump straight into the modules below. Otherwise, follow the [environment setup](#environment-setup) first.

## Training program

1. **Resource management** — see [Module 1](01-resource-management/qos/README.md)
   - Requests and limits
   - Quality of Service (QoS)
   - Limit Ranges
   - Resource Quotas
2. **Cost management** — see [Module 2](02-cost-management/scalability/hpa/README.md)
   - FinOps culture
   - Cost optimization
   - Horizontal Pod Autoscaling (HPA)
   - Event-driven autoscaling (KEDA)
   - Vertical Pod Autoscaling (VPA)
3. **Services & networking** — see [Module 3](03-services-networking/services/README.md)
   - Cluster/host networking configuration
   - Container Network Interface (CNI) plugins
   - Connectivity between Pods
   - Service types and endpoints
   - Ingress controllers and Ingress resources
4. **Security** — see [Module 4](04-security/pod-security/README.md)
   - Cloud Native Security 4Cs (Cloud, Cluster, Container, Code)
   - Pod security
   - Network security
   - Authentication, authorization, and admission control (RBAC, policy engines)
   - Zero Trust practices: audit logs, encryption of confidential data at rest, threat detection and response, minimal base images

## Modules

| # | Module | Topics | Labs |
|---|--------|--------|------|
| 1 | Resource Management | [QoS](01-resource-management/qos/README.md), [Limit Ranges](01-resource-management/limit-ranges/README.md), [Quotas](01-resource-management/quotas/README.md) | 1 + 2 + 1 |
| 2 | Cost Management → Scalability | [HPA](02-cost-management/scalability/hpa/README.md), [KEDA](02-cost-management/scalability/keda/README.md) | 1 + 1 |
| 3 | Services & Networking | [Services](03-services-networking/services/README.md), [Ingress](03-services-networking/ingress/README.md) | 3 + 1 |
| 4 | Security | [Pod Security](04-security/pod-security/README.md), [Network Security](04-security/network-security/README.md), [RBAC](04-security/rbac/README.md), [Kyverno](04-security/kyverno/README.md), [Trivy](04-security/trivy/README.md) | 2 + 8 + 3 + 1 + 4 |

Work through the modules in order: resource management establishes vocabulary (requests, limits, QoS) that cost management and security both build on, and the security modules progressively layer Pod-level, network-level, identity-level, and policy/scanning-level controls on top of one another.

## Environment setup

Like Part 1, these labs run on [minikube](https://minikube.sigs.k8s.io/docs/start/), a local single-node Kubernetes cluster.

**Prerequisites**

- 2 CPUs or more
- 2 GB of free memory
- 20 GB of free disk space
- An internet connection
- A container or virtual machine manager, such as Docker, Hyper-V, or VirtualBox

Refer to the [minikube documentation](https://minikube.sigs.k8s.io/docs/start/) for installation instructions specific to your operating system.

```bash
minikube start --driver=docker --cni=cilium
kubectl get pods -A
kubectl get namespaces
kubectl config get-contexts
```

Some modules (HPA, Ingress) additionally require minikube addons, enabled with `minikube addons enable <name>` — each module calls this out where needed.

If you are working from a remote lab environment, download the lab materials with:

```bash
scp -i key.pem -r ubuntu@<lab-host>:/home/ubuntu/KubernetesAdvancedL2Labs-v1.5.0+/ "$(pwd)"
```

Once your cluster is up and running, head to [Resource Management: QoS](01-resource-management/qos/README.md) to get started.

## Conventions used in these labs

- Commands are shown in shell code blocks and are meant to be run with `kubectl`, `helm`, or `trivy` against your local minikube cluster, as indicated.
- Placeholders you need to replace are wrapped in angle brackets, e.g. `<pod-template-hash>`.
- Every module ends with a **Clean up** section — run it before moving to the next module to avoid naming collisions and leftover resources.

Ready? Start with [Resource Management: QoS](01-resource-management/qos/README.md).
