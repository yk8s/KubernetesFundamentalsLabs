[//]: # (Confidential document - see ../../CONFIDENTIAL.md)

# Security: Kyverno

*Part of the [Kubernetes Advanced Labs](../../README.md) · Module 4 · Previous: [RBAC](../rbac/README.md) · Next: [Trivy](../trivy/README.md)*

## Overview

[Pod Security](../pod-security/README.md), [Network Security](../network-security/README.md), and [RBAC](../rbac/README.md) each secure one Pod, connection, or identity at a time, by hand. Kyverno automates that: it's a policy engine that can validate, mutate, and generate Kubernetes resources cluster-wide, so rules like "no privileged containers" are enforced automatically for every Pod, instead of relying on every manifest author to remember them.

## Objectives

By the end of this module, you will be able to:

- Explain what a Kyverno ClusterPolicy is, and the difference between `Audit` and `Enforce` validation modes.
- Install Kyverno via Helm.
- Apply a policy in audit mode and review its findings via PolicyReports, without blocking anything.
- Switch a policy to enforce mode and confirm it now blocks non-compliant Pods at admission time.

## Prerequisites

- Completion of [RBAC](../rbac/README.md).
- A running minikube cluster.

## Key concepts

### Kyverno

Kyverno is a policy engine designed specifically for Kubernetes: policies are themselves Kubernetes resources (`ClusterPolicy` / `Policy`), written in YAML rather than a separate policy language. A policy's rules can:

- **validate** — accept or reject a resource against a pattern (used in this lab).
- **mutate** — rewrite a resource on the fly (e.g. injecting labels or defaults).
- **generate** — create additional resources automatically (e.g. a default NetworkPolicy in every new namespace).
- **verify images** — check image signatures and provenance as part of a software-supply-chain policy.

A validation rule's `validationFailureAction` controls what happens when a resource doesn't match: `Audit` records a violation (visible via PolicyReports) without blocking the request, while `Enforce` rejects the request outright at admission time. The Kyverno CLI can also evaluate policies against manifests offline, e.g. as a CI/CD pipeline gate, before anything reaches the cluster.

## Lab

### Lab 1: Disallow privileged containers

**Goal:** install Kyverno, apply a policy disallowing privileged containers in audit mode, confirm it only reports violations, then switch to enforce mode and confirm it now blocks them.

Install Kyverno via Helm:

```bash
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
helm search repo kyverno -l
helm install kyverno kyverno/kyverno -n kyverno --create-namespace --set replicaCount=1
kubectl get pods -n kyverno
kubectl logs -l app.kubernetes.io/name=kyverno -n kyverno
```

Apply the policy in **audit** mode (`validationFailureAction: Audit`):

```bash
kubectl apply -f manifests/disallow-privileged-containers.yaml

kubectl get policies -A
kubectl get clusterpolicies
kubectl get policyreport -A
kubectl get clusterpolicyreport
```

Create a compliant and a non-compliant Pod, and confirm **both** are admitted — audit mode only records the violation, it doesn't block it:

```bash
kubectl create -f manifests/runasnonprivileged.yaml
kubectl create -f manifests/runasprivileged.yaml
kubectl describe po runasnonprivileged
kubectl describe po runasprivileged
kubectl get ev
```

Now switch to the **enforce** variant of the policy (`validationFailureAction: Enforce`) and repeat:

```bash
kubectl delete po runasprivileged runasnonprivileged
kubectl apply -f manifests/disallow-privileged-containers-enforced.yaml

kubectl create -f manifests/runasnonprivileged.yaml
kubectl create -f manifests/runasprivileged.yaml
kubectl describe po runasnonprivileged
kubectl get ev
```

This time, `runasprivileged.yaml` (which sets `securityContext.privileged: true`) is rejected by the API server at admission time — you'll see a Kyverno admission-webhook error referencing the `disallow-privileged-containers` policy instead of a Pod being created, and `runasnonprivileged` is unaffected either way.

## Clean up

```bash
kubectl delete -f ./manifests
helm uninstall kyverno -n kyverno
kubectl delete namespace kyverno
```

## Further reading

- [Kyverno documentation](https://kyverno.io/docs/)
- [Kyverno Policy Library](https://kyverno.io/policies/) — pre-built policies, including Pod Security Standards baselines
- [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/) — the standard this lab's policy implements

---
Previous: [RBAC](../rbac/README.md) · Next: [Trivy](../trivy/README.md)
