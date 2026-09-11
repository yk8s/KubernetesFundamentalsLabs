[//]: # (Confidential document - see ../../CONFIDENTIAL.md)

# Security: RBAC

*Part of the [Kubernetes Advanced Labs](../../README.md) · Module 4 · Previous: [Network Security](../network-security/README.md) · Next: [Kyverno](../kyverno/README.md)*

## Overview

Where [Network Security](../network-security/README.md) controlled what a Pod can talk to, Role-Based Access Control (RBAC) controls what an identity — a user, or a Pod acting as a ServiceAccount — can do *against the Kubernetes API itself*. This module creates a ServiceAccount scoped to a narrow set of permissions, verifies those permissions with `kubectl auth can-i`, and builds a standalone kubeconfig so you can authenticate as that ServiceAccount directly.

## Objectives

By the end of this module, you will be able to:

- Explain the relationship between a Role, a RoleBinding, and a ServiceAccount.
- Create a Role scoped to specific resources and verbs, and bind it to a ServiceAccount.
- Check what an identity is authorized to do with `kubectl auth can-i`.
- Build a standalone kubeconfig for a ServiceAccount and use it to authenticate.
- Generate a ServiceAccount API token, and decode a JWT to inspect its claims.

## Prerequisites

- Completion of [Network Security](../network-security/README.md).
- A running minikube cluster (RBAC is enabled by default; on a self-managed cluster, the API server needs `--authorization-mode` to include `RBAC`).
- `dos2unix` available, or a Unix-native shell, to run the provided script.

## Key concepts

### RBAC

RBAC is a method of regulating access to resources based on the roles of individual identities in your organization. In Kubernetes, RBAC authorization uses the `rbac.authorization.k8s.io` API group, letting you configure "who can do what" declaratively, through the same API you use for every other object.

The RBAC object model has four pieces:

- **Role** / **ClusterRole** — a set of rules, each granting `verbs` (`get`, `list`, `watch`, `create`, `update`, `delete`, …) on specific `resources` within specific `apiGroups`. A `Role` is namespaced; a `ClusterRole` applies cluster-wide or can be reused across namespaces.
- **RoleBinding** / **ClusterRoleBinding** — grants the permissions in a Role/ClusterRole to one or more subjects (users, groups, or ServiceAccounts). A `RoleBinding` grants access only within its own namespace, even when it references a `ClusterRole`.
- **ServiceAccount** — an identity for processes running *inside* the cluster (typically, Pods), as opposed to human users authenticated externally.

## Labs

### Lab 1: Role and RoleBinding

**Goal:** create a Namespace, a ServiceAccount, a long-lived token Secret for it, a Role, and a RoleBinding — then verify the resulting permissions.

```bash
kubectl create -f manifests/rbac.yaml
kubectl get serviceaccount -n rbac
kubectl get roles -n rbac
kubectl get rolebinding -n rbac
kubectl describe roles -n rbac
kubectl auth can-i get pods --as=system:serviceaccount:rbac:dev-service-account
kubectl auth can-i get cm --as=system:serviceaccount:rbac:dev-service-account
kubectl auth can-i get cm --as=system:serviceaccount:rbac:dev-service-account -n rbac
```

`manifests/rbac.yaml` grants `dev-service-account` full access (`*`) to StatefulSets, Services, ConfigMaps, Secrets, and PersistentVolumeClaims/Volumes, plus read-only access to ResourceQuotas — but **only within the `rbac` namespace**, and says nothing about Pods. Compare the three `can-i` checks above: the ServiceAccount can read ConfigMaps in `rbac`, but neither Pods nor ConfigMaps outside it (the `default` namespace, implied when `-n` is omitted).

### Lab 2: Authenticate as the ServiceAccount

**Goal:** build a standalone kubeconfig for `dev-service-account` from the token Secret created in Lab 1, and use it to confirm the same permission boundary from a fresh `kubectl` session.

```bash
dos2unix manifests/kubeconfig.sh
chmod +x manifests/kubeconfig.sh
./manifests/kubeconfig.sh rbac dev-service-account dev-secret
kubectl --kubeconfig=kubeconfig-rbac get po
kubectl --kubeconfig=kubeconfig-rbac get cm
kubectl --kubeconfig=kubeconfig-rbac get cm -n rbac
```

`kubeconfig.sh <namespace> <service-account> <secret-name>` reads the bearer token out of the given Secret, and writes a new kubeconfig file (`kubeconfig-<namespace>`) authenticating as that token against your current cluster's API server. The results should match Lab 1's `can-i` checks exactly — this is the same authorization boundary, exercised through a real `kubectl` session instead of a dry-run check.

### Lab 3: Tokens

**Goal:** look at a Pod's automatically mounted ServiceAccount token, then generate one manually and inspect its structure.

```bash
kubectl run --restart=Never busybox -it --image=busybox --rm --quiet -- \
  cat /var/run/secrets/kubernetes.io/serviceaccount/token
```

Every Pod automatically gets a token for its ServiceAccount (`default`, unless overridden) mounted at this path — this is how in-cluster applications (controllers, operators, CI jobs) normally authenticate to the API server.

```bash
kubectl create ns dev2
kubectl create sa demo -n dev2
kubectl create token demo -n dev2
kubectl create token demo --duration=999999h -n dev2
```

The token is a JSON Web Token (JWT) — three base64-encoded, dot-separated segments (header, payload, signature). [jwt.io](https://jwt.io) is a convenient way to decode one and inspect its claims (issuer, subject, expiry) without writing any code — paste only the token itself, never one issued against a real production cluster, since decoding it is enough to read its claims (though not to forge a new, validly signed one).

## Clean up

```bash
kubectl delete -f manifests/rbac.yaml
kubectl delete ns dev2
rm -f kubeconfig-rbac
```

## Further reading

- [Using RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [Managing Service Accounts](https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/)
- [Configure Service Accounts for Pods](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/)
- [jwt.io](https://jwt.io) — JWT decoder used in Lab 3

---
Previous: [Network Security](../network-security/README.md) · Next: [Kyverno](../kyverno/README.md)
