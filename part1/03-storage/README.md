[//]: # (Confidential document - see ../CONFIDENTIAL.md)

# Module 3: Storage

*Part of the [Kubernetes Fundamentals Labs](../README.md) · Module 3 of 6 · Previous: [Workloads](../02-workloads/README.md) · Next: [Configuration](../04-configuration/README.md)*

## Overview

This module covers how Kubernetes attaches storage to Pods, from simple ephemeral volumes to dynamically provisioned persistent storage. You'll create a Pod with a shared, ephemeral volume, then request persistent storage through a PersistentVolumeClaim backed by a StorageClass.

## Objectives

By the end of this module, you will be able to:

- Explain the difference between a Volume, a PersistentVolume (PV), a PersistentVolumeClaim (PVC), and a StorageClass.
- Attach a volume to a Pod and mount it into one or more containers, read-write or read-only.
- Describe a StorageClass and use it to dynamically provision storage for a PVC.

## Prerequisites

- Completion of [Module 2: Workloads](../02-workloads/README.md).
- A running minikube cluster (minikube ships with a default `standard` StorageClass backed by `hostPath`, which this module uses).

## Key concepts

### Volumes

A Volume is storage that is tied to a Pod's lifecycle rather than a container's: it survives container restarts within the same Pod, and can be shared between the containers of that Pod. Whether the volume's data survives the Pod being deleted depends entirely on the volume type — an `emptyDir` volume, for example, is deleted with the Pod, while a volume backed by a PersistentVolumeClaim is not.

A Pod's containers reference volumes by name in their `volumeMounts`, specifying the `mountPath` inside the container and, optionally, whether the mount is read-only.

### PersistentVolumes and PersistentVolumeClaims

PersistentVolumes and PersistentVolumeClaims work together to give a Pod persistent storage that outlives the Pod itself:

- A **PersistentVolume (PV)** represents a piece of cluster-wide storage capacity, backed by an external provider — NFS, a cloud disk, Ceph RBD, and so on.
- A **PersistentVolumeClaim (PVC)** is a namespaced *request* for storage that meets a set of requirements (size, access mode, storage class) rather than a reference to a specific PV.

This separation means an application's claim for storage is portable: the same PVC manifest works regardless of which storage backend actually satisfies it.

### StorageClasses

A StorageClass is an abstraction over an external storage provider that enables **dynamic provisioning**: instead of a cluster administrator pre-creating PVs by hand, the StorageClass's provisioner creates a PV on demand whenever a matching PVC is created. A StorageClass can be targeted explicitly by name (`storageClassName`) or configured as the cluster default, so that PVCs which don't specify one are still satisfied.

## Labs

### Lab 1: Volumes

**Goal:** create a Pod with an `emptyDir` volume shared between two containers, and observe read-write vs. read-only mounts.

```bash
kubectl create -f manifests/volume-example.yaml
kubectl exec volume-example -c content -- /bin/sh -c "cat /html/index.html"
kubectl exec volume-example -c nginx -- /bin/sh -c "cat /usr/share/nginx/html/index.html"
kubectl exec volume-example -c nginx -- /bin/sh -c "echo nginx >> /usr/share/nginx/html/index.html"
```

Both containers mount the same `emptyDir` volume at different paths (`/html` and `/usr/share/nginx/html`), so a file written by one container is immediately visible to the other.

### Lab 2: Persistent Volumes and Storage Classes

**Goal:** inspect the default StorageClass, create a PVC that dynamically provisions a PV, and confirm the resulting PV.

```bash
kubectl describe sc standard
kubectl create -f manifests/pvc-standard.yaml
kubectl describe pvc pvc-standard
kubectl get pv
```

Note that no PV existed before you created the PVC — the `standard` StorageClass's provisioner created one automatically to satisfy the claim's request.

## Clean up

```bash
kubectl delete -f manifests/
```

## Further reading

- [Volumes](https://kubernetes.io/docs/concepts/storage/volumes/)
- [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- [Storage Classes](https://kubernetes.io/docs/concepts/storage/storage-classes/)
- [Dynamic Volume Provisioning](https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/)

---
Previous: [Module 2: Workloads](../02-workloads/README.md) · Next: [Module 4: Configuration](../04-configuration/README.md)
