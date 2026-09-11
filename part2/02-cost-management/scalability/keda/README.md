[//]: # (Confidential document - see ../../../CONFIDENTIAL.md)

# Cost Management: KEDA (Event-Driven Autoscaling)

*Part of the [Kubernetes Advanced Labs](../../../README.md) · Module 2 · Previous: [HPA](../hpa/README.md) · Next: [Services & Networking: Services](../../../03-services-networking/services/README.md)*

## Overview

The built-in [HPA](../hpa/README.md) scales on resource metrics like CPU and memory — a reasonable proxy for load in many applications, but a poor one for workloads whose real bottleneck is a queue of pending work (messages, jobs, events) rather than CPU. KEDA (Kubernetes Event-Driven Autoscaler) extends autoscaling to scale on that queue depth directly, and can scale a Deployment to and from **zero** replicas when there's no work at all — something the standard HPA cannot do on its own.

## Objectives

By the end of this module, you will be able to:

- Explain how KEDA extends, rather than replaces, the standard HorizontalPodAutoscaler.
- Install KEDA via Helm.
- Deploy a RabbitMQ broker and a consumer application scaled by a KEDA `ScaledObject`.
- Publish messages to a queue and observe KEDA scale the consumer to match.

## Prerequisites

- Completion of [HPA](../hpa/README.md).
- Completion of [Part 1: Helm](../../../../part1/05-helm/README.md) (this lab installs charts via `helm install`).
- A running minikube cluster with outbound internet access (to pull the RabbitMQ image and clone a sample repository).

## Key concepts

### KEDA

KEDA is a single-purpose, lightweight component that can be added to any Kubernetes cluster to drive scaling based on the number of events a workload needs to process — for example, messages waiting in a RabbitMQ queue, or items in a Kafka topic. It works alongside the standard HPA rather than replacing it: under the hood, KEDA creates and manages an HPA object for you, translating an event source's metrics (via a KEDA *scaler*) into the metrics the HPA understands. Because you explicitly opt individual workloads into event-driven scaling via a `ScaledObject`, KEDA can run safely alongside other applications that continue to scale (or not) exactly as before.

## Lab

### Lab 1: Scale a RabbitMQ consumer

**Goal:** install KEDA and RabbitMQ, deploy a sample consumer with a KEDA `ScaledObject`, and watch it scale as messages are published to the queue.

Install KEDA into its own namespace via Helm:

```bash
helm repo add kedacore https://kedacore.github.io/charts
helm repo update
kubectl create namespace keda
helm install keda kedacore/keda --namespace keda
```

Install RabbitMQ via the Bitnami chart:

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install rabbitmq bitnami/rabbitmq \
  --set auth.username=user \
  --set auth.password=PASSWORD \
  --set image.repository=bitnami/rabbitmq \
  --set image.digest=sha256:fac502149c400b0e373520f02ff8288114b57d9209019b15f5695947c9dbb14d \
  --wait
kubectl get po
```

> Replace `PASSWORD` with a value of your choice — it's the RabbitMQ user's password for the rest of this lab.

Deploy the sample consumer, which includes a KEDA `ScaledObject` targeting the RabbitMQ queue:

```bash
git clone https://github.com/kedacore/sample-go-rabbitmq
cd sample-go-rabbitmq
kubectl apply -f deploy/deploy-consumer.yaml
kubectl get deploy
```

Publish a batch of messages to the queue and watch KEDA scale the consumer's HPA in response:

```bash
kubectl apply -f deploy/deploy-publisher-job.yaml
kubectl get hpa --watch
```

## Clean up

```bash
kubectl delete job rabbitmq-publish
kubectl delete ScaledObject rabbitmq-consumer
kubectl delete deploy rabbitmq-consumer
helm delete rabbitmq
helm delete keda -n keda
```

## Further reading

- [KEDA documentation](https://keda.sh/docs/latest/)
- [KEDA Scalers](https://keda.sh/docs/latest/scalers/) — the full list of event sources KEDA can scale on
- [sample-go-rabbitmq](https://github.com/kedacore/sample-go-rabbitmq) — the sample project used in this lab

---
Previous: [HPA](../hpa/README.md) · Next: [Services & Networking: Services](../../../03-services-networking/services/README.md)
