[//]: # (Confidential document - see ../CONFIDENTIAL.md)

# Module 4: Configuration

*Part of the [Kubernetes Fundamentals Labs](../README.md) · Module 4 of 6 · Previous: [Storage](../03-storage/README.md) · Next: [Helm](../05-helm/README.md)*

## Overview

Kubernetes decouples configuration from application code and container images through two objects: ConfigMaps for non-sensitive data, and Secrets for sensitive data. Both are created and consumed the same way, so this module builds the ConfigMap lab first, then repeats the pattern with Secrets so you can focus on the (small) differences.

## Objectives

By the end of this module, you will be able to:

- Create a ConfigMap from a manifest, from literal values, from a directory, and from individual files.
- Inject ConfigMap data into a Pod as environment variables, as command-line arguments, and as mounted files.
- Create a Secret using the same four methods, and explain how Secrets differ from ConfigMaps.
- Consume Secret data as environment variables and as mounted files.

## Prerequisites

- Completion of [Module 3: Storage](../03-storage/README.md) (Secret and ConfigMap volume mounts build on the volume concepts from that module).

## Key concepts

### ConfigMaps

A ConfigMap stores non-sensitive, externalized configuration data as key/value pairs inside `etcd`. You can create one four ways with `kubectl`:

- From a **manifest** (a YAML file with `kind: ConfigMap`)
- From **literals** passed directly on the command line
- From a **directory**, where every file becomes one key
- From individual **files**, named explicitly

Once created, a ConfigMap's data can be consumed by a Pod in three ways:

- As **environment variables**, picked up by the application directly or referenced in a command-line argument
- As a **mounted volume**, exposing every key as a file — optionally restricted to specific items, renamed, or mounted read-only

### Secrets

A Secret stores the same kind of key/value data as a ConfigMap, but is intended for sensitive values such as credentials or tokens. Secret data is stored **base64-encoded**, not encrypted — base64 is an encoding, not an encryption scheme, so a Secret's confidentiality depends on the cluster's access controls (RBAC) and, ideally, [encryption at rest](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/) for `etcd`, not on the encoding itself.

Secrets are created and consumed exactly like ConfigMaps (manifest, literal, directory, file; environment variable, command-line argument, or mounted volume), with one visible difference: a Secret manifest has a `type` field. `Opaque` — the type used in this lab — simply means the data has no special structure that Kubernetes needs to understand.

## Labs

### Lab 1: ConfigMaps

**Goal:** create a ConfigMap using all four creation methods, then consume one via environment variables and via a mounted volume.

```bash
kubectl create -f manifests/cm-manifest.yaml
kubectl get configmap manifest-example -o yaml

kubectl create cm literal-example --from-literal="city=Ann Arbor" --from-literal=state=Michigan
kubectl get cm literal-example -o yaml

kubectl create cm dir-example --from-file=manifests/cm/
kubectl get cm dir-example -o yaml

kubectl create cm file-example --from-file=manifests/cm/city --from-file=manifests/cm/state
kubectl get cm file-example -o yaml

kubectl create -f manifests/cm-env-example.yaml
kubectl get pods
kubectl logs cm-env-example-<pod-id>

kubectl create -f manifests/cm-cmd-example.yaml
kubectl get pods
kubectl logs cm-cmd-example-<pod-id>

kubectl delete job cm-env-example cm-cmd-example

kubectl create -f manifests/cm-vol-example.yaml
kubectl exec cm-vol-example -- ls /myconfig
kubectl exec cm-vol-example -- /bin/sh -c "cat /myconfig/*"
kubectl exec cm-vol-example -- ls /mycity
kubectl exec cm-vol-example -- cat /mycity/thisismycity

kubectl delete pod cm-vol-example
kubectl delete cm dir-example file-example literal-example manifest-example
```

### Lab 2: Secrets

**Goal:** repeat the ConfigMap exercise with Secrets, and confirm the data is base64-decoded correctly at runtime.

If you've completed Lab 1, this lab will feel familiar — the commands only differ in the resource name (`secret` vs. `cm`) and the extra `type` field. The manifest's `data` values (`ZXhhbXBsZQ==` and `bXlwYXNzd29yZA==`) decode to `username=example` and `password=mypassword`.

```bash
kubectl create -f manifests/secret-manifest.yaml
kubectl get secret manifest-example -o yaml

kubectl create secret generic literal-example --from-literal=username=example --from-literal=password=mypassword
kubectl get secret literal-example -o yaml

kubectl create secret generic dir-example --from-file=manifests/secret/
kubectl get secret dir-example -o yaml

kubectl create secret generic file-example --from-file=manifests/secret/username --from-file=manifests/secret/password
kubectl get secret file-example -o yaml

kubectl create -f manifests/secret-env-example.yaml
kubectl get pods
kubectl logs secret-env-example-<pod-id>

kubectl create -f manifests/secret-cmd-example.yaml
kubectl get pods
kubectl logs secret-cmd-example-<pod-id>

kubectl delete job secret-env-example secret-cmd-example

kubectl create -f manifests/secret-vol-example.yaml
kubectl exec secret-vol-example -- ls /mysecret
kubectl exec secret-vol-example -- /bin/sh -c "cat /mysecret/*"
kubectl exec secret-vol-example -- ls /mypass
kubectl exec secret-vol-example -- cat /mypass/supersecretpass

kubectl delete pod secret-vol-example
kubectl delete secret dir-example file-example literal-example manifest-example
```

## Clean up

```bash
kubectl delete -f manifests/
```

## Further reading

- [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/)
- [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [Encrypting Confidential Data at Rest](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/) — relevant to Secrets, and revisited in [Part 2: Security](../../part2/04-security/rbac/README.md)

---
Previous: [Module 3: Storage](../03-storage/README.md) · Next: [Module 5: Helm](../05-helm/README.md)
