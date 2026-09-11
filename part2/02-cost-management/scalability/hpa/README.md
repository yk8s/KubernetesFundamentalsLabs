[//]: # (Confidential document - see ../../../CONFIDENTIAL.md)

# Cost Management: Horizontal Pod Autoscaler (HPA)

*Part of the [Kubernetes Advanced Labs](../../../README.md) · Module 2 · Previous: [Resource Management: Quotas](../../../01-resource-management/quotas/README.md) · Next: [KEDA](../keda/README.md)*

## Overview

The Horizontal Pod Autoscaler (HPA) automatically adjusts the replica count of a Deployment or StatefulSet to match observed demand — scaling out under load and back in when load subsides, instead of a human (or a fixed replica count) guessing capacity ahead of time. This is one of the primary levers for cost management in Kubernetes: over-provisioned replicas cost money whether or not they're doing useful work, so autoscaling to the metric that actually reflects load is both a reliability and a cost-efficiency practice.

## Objectives

By the end of this module, you will be able to:

- Explain the difference between horizontal and vertical scaling.
- Enable the metrics-server addon that the HPA depends on.
- Create an HPA that targets average CPU utilization, and watch it react to load.

## Prerequisites

- Completion of [Resource Management: Quotas](../../../01-resource-management/quotas/README.md) (the HPA scales based on the same `requests` you used there).
- A running minikube cluster.

## Key concepts

### Horizontal vs. vertical scaling

**Horizontal** scaling responds to increased load by running *more* Pods; **vertical** scaling responds by giving the *existing* Pods more resources (CPU/memory). The HPA performs horizontal scaling only — it does not apply to objects that can't be replicated, such as a DaemonSet, whose replica count is tied to the number of Nodes rather than being freely adjustable.

### How the HPA works

The HorizontalPodAutoscaler is both a Kubernetes API resource (the desired scaling behavior: target, min/max replicas, target metric) and a controller running in the control plane that periodically compares observed metrics — average CPU utilization, average memory utilization, or a custom metric — against the target, and adjusts the target workload's replica count accordingly. CPU-based autoscaling (used in this lab) depends on the **metrics-server** addon being installed in the cluster, since that's what the HPA controller queries for current utilization.

## Lab

### Lab 1: Scale php-apache under load

**Goal:** enable metrics-server, deploy a CPU-bound application with an HPA attached, generate load against it, and watch the HPA scale it out.

```bash
minikube addons enable metrics-server

kubectl create -f manifests/php-apache-deploy.yaml
kubectl get po

kubectl create -f manifests/php-apache-hpa.yaml
kubectl get hpa
```

The `php-apache` Deployment requests `200m` CPU and limits at `500m`; the HPA targets 50% average CPU utilization (of the *request*) and can scale between 1 and 10 replicas.

In a **second terminal**, generate sustained load against the Service:

```bash
kubectl run -it --rm load-generator --image=busybox /bin/sh
# inside the container:
while true; do wget -q -O- http://php-apache.default.svc.cluster.local; done
```

Back in your first terminal, watch CPU utilization climb and the HPA react by adding replicas — this typically takes a minute or so to show up, since the HPA controller polls metrics on an interval rather than reacting instantly:

```bash
kubectl get hpa
kubectl get deployment php-apache
```

Stop the load generator (`Ctrl+C`, then exit the shell, or delete the Pod) and re-run the same two commands a few minutes later to watch the HPA scale back down toward `minReplicas`.

## Clean up

```bash
kubectl delete deploy php-apache
kubectl delete svc php-apache
kubectl delete hpa php-apache
kubectl delete pod load-generator
```

## Further reading

- [Horizontal Pod Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
- [HorizontalPodAutoscaler Walkthrough](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/)
- [metrics-server](https://github.com/kubernetes-sigs/metrics-server)

---
Previous: [Resource Management: Quotas](../../../01-resource-management/quotas/README.md) · Next: [KEDA](../keda/README.md)
