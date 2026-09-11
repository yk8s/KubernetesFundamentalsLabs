[//]: # (Confidential document - see ../CONFIDENTIAL.md)

# Module 2: Workloads

*Part of the [Kubernetes Fundamentals Labs](../README.md) · Module 2 of 6 · Previous: [Core Concepts](../01-core/README.md) · Next: [Storage](../03-storage/README.md)*

## Overview

Workloads are higher-level objects that manage Pods (or other higher-level objects) on your behalf: they decide how many replicas to run, how to roll out updates, where to schedule Pods, and how to run one-off or scheduled tasks. This module walks through the six workload controllers you'll use most often, from the simplest (ReplicaSet) to the most specialized (CronJob).

## Objectives

By the end of this module, you will be able to:

- Explain the relationship between a ReplicaSet, a Deployment, and the Pods they own.
- Create, scale, and delete a ReplicaSet directly, and understand why you rarely do this in practice.
- Create a Deployment, roll out an update, view its revision history, and roll back to a previous revision.
- Create a DaemonSet and understand how node labels affect its scheduling.
- Create a StatefulSet and observe how it differs from a Deployment in naming, ordering, and storage.
- Run a one-off task with a Job, and a scheduled task with a CronJob.

## Prerequisites

- Completion of [Module 1: Core Concepts](../01-core/README.md) (this module assumes you understand Pods, Labels, and Selectors).
- A running minikube cluster with the `dev` Namespace created in Module 1.

## Key concepts

### ReplicaSets

A ReplicaSet's job is simple: always keep the desired number of Pod replicas matching its selector running. It handles scheduling, scaling, and replacing failed Pods, but has no concept of a rollout — updating a ReplicaSet's Pod template does not update existing Pods. In practice, you rarely create a ReplicaSet directly; instead you manage it indirectly through a Deployment.

### Deployments

A Deployment is a declarative way to manage Pods via one or more ReplicaSets underneath. It adds what a bare ReplicaSet lacks: controlled rollouts (creating a new ReplicaSet and scaling it up while scaling the old one down), rollout history, and rollback. This makes Deployments the default choice for stateless workloads.

### DaemonSets

A DaemonSet ensures that every Node matching its scheduling constraints runs exactly one copy of a given Pod. Unlike a Deployment, it does not use a replica count — the number of Pods is tied to the number of matching Nodes. DaemonSets are the standard pattern for cluster-wide, per-node services such as log forwarders, metrics collectors, or network agents.

### StatefulSets

A StatefulSet manages Pods that need a stable identity — hostname, network identity, and storage — across restarts and rescheduling. It provides this by combining three mechanisms:

- **Predictable naming and ordered lifecycle:** Pods are named `<statefulset-name>-0`, `-1`, `-2`, … and are created, updated, and deleted in that order (one at a time, by default).
- **A headless Service:** gives each Pod a stable DNS name, independent of which Node it's scheduled on.
- **Volume claim templates:** each Pod gets its own PersistentVolumeClaim, which is preserved (not deleted) when the Pod is rescheduled or deleted.

### Jobs

A Job runs one or more Pods to completion — it's a task executor rather than a long-running service. The Job controller retries failed Pods and tracks successful completions; `completions` and `parallelism` control how many successful runs are required and how many Pods may run at once.

### CronJobs

A CronJob is a Job that runs on a recurring schedule, expressed as a standard cron expression. Each scheduled run creates a new Job (and its own Pods) from the CronJob's Job template.

## Labs

### Lab 1: ReplicaSets

**Goal:** create and scale a ReplicaSet directly, and see how it reacts to a manually created Pod that matches its selector.

```bash
kubectl create -f manifests/rs-example.yaml
kubectl get pods --watch --show-labels
kubectl describe rs rs-example
kubectl scale replicaset rs-example --replicas=5
kubectl describe rs rs-example
kubectl scale rs rs-example --replicas=3
kubectl get pods --show-labels --watch
kubectl create -f manifests/pod-rs-example.yaml
kubectl get pods --show-labels --watch
kubectl describe rs rs-example
kubectl delete rs rs-example
```

The independently created Pod in `pod-rs-example.yaml` carries the same labels as the ReplicaSet's selector. Watch what happens to it: the ReplicaSet is already at its desired replica count, so it treats the extra Pod as surplus and terminates it almost immediately.

### Lab 2: Deployments

**Goal:** create a Deployment, update its Pod template, inspect the rollout, and roll back to an earlier revision.

```bash
kubectl create -f manifests/deploy-example.yaml
kubectl get deployments
kubectl get rs --show-labels
kubectl describe rs deploy-example-<pod-template-hash>
kubectl get pods --show-labels
kubectl describe pod deploy-example-<pod-template-hash>-<random>
```

Now edit `manifests/deploy-example.yaml` (or use the provided `deploy-example-update.yaml`) to add a `version: 1.0.0` label to the Pod template:

```yaml
template:
  metadata:
    labels:
      app: nginx
      version: 1.0.0
```

```bash
kubectl apply -f manifests/deploy-example-update.yaml
kubectl get pods --show-labels --watch
kubectl get rs --show-labels
kubectl scale deploy deploy-example --replicas=5
kubectl get rs --show-labels
kubectl describe deploy deploy-example
kubectl describe rs deploy-example-<pod-template-hash>
kubectl describe pod deploy-example-<pod-template-hash>-<random>

kubectl rollout history deployment deploy-example
kubectl rollout history deployment deploy-example --revision=1
kubectl rollout history deployment deploy-example --revision=2
kubectl rollout undo deployment deploy-example --to-revision=1
kubectl get pods --show-labels --watch
kubectl describe deployment deploy-example
kubectl delete deploy deploy-example
```

> **Note:** older versions of these labs used `kubectl create/apply ... --record` to annotate the rollout history with the command that triggered it. The `--record` flag is deprecated in current versions of `kubectl` (and may print a warning, or be rejected entirely on very recent releases) — it's safe to omit; `rollout history` still works without it.

### Lab 3: DaemonSets

**Goal:** create a DaemonSet, label a Node so it matches the DaemonSet's node selector, and confirm a Pod is scheduled onto it.

```bash
kubectl create -f manifests/ds-example.yaml
kubectl get daemonset
kubectl label node minikube nodeType=edge
kubectl get daemonsets
kubectl get pods --show-labels
kubectl delete ds ds-example
```

### Lab 4: StatefulSets

**Goal:** create a StatefulSet, observe ordered Pod naming and per-Pod storage, and see what happens to storage when a Pod is deleted or the set is scaled.

```bash
kubectl create -f manifests/sts-example.yaml
kubectl get pods --show-labels --watch
kubectl describe statefulset sts-example
kubectl get pvc
kubectl delete pod sts-example-2
kubectl get pods

kubectl scale sts sts-example --replicas=5
kubectl get pods
kubectl get pvc
kubectl scale sts sts-example --replicas=3
kubectl get pods
kubectl get pvc
kubectl delete sts sts-example
kubectl delete pvc --all
```

Notice that scaling the StatefulSet back down does **not** delete the PersistentVolumeClaims created for the higher-numbered Pods — StatefulSets never delete storage on your behalf, by design.

### Lab 5: Job

**Goal:** run a Job to completion and observe its Pods.

```bash
kubectl create -f manifests/job-example.yaml
kubectl get pods --show-labels --watch
kubectl describe job job-example
kubectl delete job job-example
kubectl get pods
```

### Lab 6: CronJob

**Goal:** create a CronJob that runs every minute (`*/1 * * * *`) and observe the Jobs it spawns.

```bash
kubectl create -f manifests/cronjob-example.yaml
kubectl get jobs --watch
kubectl describe cronjob cronjob-example
kubectl delete cronjob cronjob-example
```

## Clean up

```bash
kubectl delete -f manifests/
```

## Further reading

- [ReplicaSet](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/)
- [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)
- [StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)
- [Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/)
- [CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/)

---
Previous: [Module 1: Core Concepts](../01-core/README.md) · Next: [Module 3: Storage](../03-storage/README.md)
