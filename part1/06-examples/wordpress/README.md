[//]: # (Confidential document - see ../../CONFIDENTIAL.md)

# Module 6: Examples — WordPress

*Part of the [Kubernetes Fundamentals Labs](../../README.md) · Module 6 of 6 · Previous: [Helm](../../05-helm/README.md)*

## Overview

This module ties together everything from Modules 1–4 (workloads, storage, and configuration) into one realistic, multi-tier application: a WordPress site backed by a MySQL database. Unlike the previous modules, there isn't a lab-by-lab breakdown — instead, read through the manifests in `manifests/` to see how a real application composes the objects you've already learned individually.

## Objectives

By the end of this module, you will be able to:

- Deploy a multi-tier application from a set of manifests in a single command.
- Identify how each object in the WordPress example (Secret, StatefulSet, PVC, Services, Deployment) maps to what you learned in Modules 1–4.
- Reach the deployed application from your browser.

## Prerequisites

- Completion of Modules 1–4 ([Core Concepts](../../01-core/README.md), [Workloads](../../02-workloads/README.md), [Storage](../../03-storage/README.md), [Configuration](../../04-configuration/README.md)).

## Key concepts

### A multi-tier example

WordPress is a widely used blogging and CMS engine, and a good introduction to multi-tier applications because it cleanly separates two concerns:

- **MySQL** — the backing datastore, run as a StatefulSet (so it gets stable storage and a stable network identity — see [Module 2: Workloads](../../02-workloads/README.md#statefulsets)) with its credentials supplied via a Secret (see [Module 4: Configuration](../../04-configuration/README.md#secrets)).
- **WordPress** — the Apache/PHP application server, run as a Deployment, that connects to MySQL over a headless/ClusterIP Service (see [Module 1: Core Concepts](../../01-core/README.md#services)) and stores uploaded media on its own PersistentVolumeClaim (see [Module 3: Storage](../../03-storage/README.md)).

It is worth reading every manifest in `manifests/` before deploying, to see exactly how these pieces reference each other (environment variables sourced from the Secret, the Service name MySQL is reached at, the volumes each Pod mounts).

## Lab

### Lab 1: Deploy WordPress

**Goal:** deploy the full application from its manifests and reach it in your browser.

```bash
kubectl create -f manifests/
kubectl get pods
kubectl get secrets
kubectl get svc
kubectl port-forward --address 0.0.0.0 svc/wordpress 8888:80
```

Once the port-forward is running, browse to `http://127.0.0.1:8888` (or `http://<public-ip>:8888` on a remote cluster) to complete the WordPress setup wizard.

## Clean up

```bash
kubectl delete -f manifests/
kubectl delete pvc mysql-data-mysql-0
```

The PersistentVolumeClaim created for the MySQL StatefulSet is not removed by `kubectl delete -f manifests/` — as covered in [Module 2](../../02-workloads/README.md#statefulsets), StatefulSets never delete PVCs automatically, so it must be deleted explicitly.

## Further reading

- [Running a Single-Instance Stateful Application](https://kubernetes.io/docs/tasks/run-application/run-single-instance-stateful-application/)
- [StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)

---
Previous: [Module 5: Helm](../../05-helm/README.md) · Back to: [Kubernetes Fundamentals Labs](../../README.md)
