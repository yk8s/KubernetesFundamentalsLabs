[//]: # (Confidential document - see ../../CONFIDENTIAL.md)

# Security: Network Policies

*Part of the [Kubernetes Advanced Labs](../../README.md) · Module 4 · Previous: [Pod Security](../pod-security/README.md) · Next: [RBAC](../rbac/README.md)*

## Overview

Where [Pod Security](../pod-security/README.md) constrained what a container can do on its Node, NetworkPolicies constrain what a Pod can talk to *over the network*. This module works through eight progressively more specific scenarios — from "deny everything" to "allow only these Pods, in this labeled namespace, on this port" — building the vocabulary you need to design least-privilege network access for real applications.

## Objectives

By the end of this module, you will be able to:

- Explain Kubernetes' default (fully open) Pod-to-Pod networking behavior, and how a NetworkPolicy changes it.
- Write a NetworkPolicy that denies or allows all ingress traffic to a set of Pods.
- Scope an `ingress` rule to specific Pods using a `podSelector`, to an entire namespace using a `namespaceSelector`, or to a combination of both.
- Reason about which NetworkPolicies apply to a given Pod, and how multiple policies combine.

## Prerequisites

- Completion of [Pod Security](../pod-security/README.md).
- A running minikube cluster with a CNI plugin that enforces NetworkPolicies (the `cilium` CNI used in this course's [environment setup](../../README.md#environment-setup) does; the default `kindnet`/bridge CNI on some minikube installs does not).

## Key concepts

### NetworkPolicies

A NetworkPolicy is an application-centric object that specifies how a Pod is allowed to communicate with other network "entities" — other Pods, namespaces, or IP blocks. A policy applies to any Pod matched by its `podSelector`, and affects only connections with at least one end inside that selection; it has no effect on unrelated traffic elsewhere in the cluster.

**By default, with no NetworkPolicy in a namespace, all ingress and egress traffic to and from its Pods is allowed.** A NetworkPolicy is additive and selector-scoped: as soon as *any* policy selects a given Pod for a given direction (`Ingress` or `Egress`), that direction becomes deny-by-default for that Pod, and only traffic matching at least one rule from at least one applicable policy is allowed. Policies never explicitly "deny" traffic — they only grant it; the deny effect comes from a Pod being selected without a matching allow rule.

### Selecting traffic sources

An `ingress` rule's `from` list can combine:

- `podSelector` — Pods matching these labels, in the **same namespace** as the policy (unless combined with a `namespaceSelector`, see below).
- `namespaceSelector` — every Pod in namespaces matching these labels.
- Both together **inside the same list entry** — Pods matching `podSelector` **and** in a namespace matching `namespaceSelector` (a logical AND).
- Both as **separate list entries** — a logical OR: matches either condition independently.

An empty selector (`{}`) matches everything of that kind — `podSelector: {}` selects every Pod in the namespace; `namespaceSelector: {}` selects every namespace, including the policy's own.

## Labs

Each lab is self-contained: it creates its own test Pods/Services and cleans them up at the end, so you can run them in order or skip to the ones you're interested in.

### Lab 1: Deny all traffic to an application

**Goal:** confirm traffic is allowed by default, then apply a policy that denies all ingress to a Pod.

```bash
kubectl run web --image=nginx --labels app=web --expose --port 80
kubectl run --rm -i -t --image=alpine test-wget -- sh
# wget -qO- http://web        # succeeds: no policy yet, default allow

kubectl apply -f manifests/web-deny-all.yaml

kubectl run --rm -i -t --image=alpine test-wget -- sh
# wget -qO- --timeout=2 http://web    # times out: web-deny-all selects app=web with no ingress rules

kubectl delete po,service web
kubectl delete networkpolicy web-deny-all
```

`web-deny-all.yaml` selects `app: web` and sets an empty `ingress: []` — the Pod is selected for ingress filtering, but no rule grants access, so every connection is dropped.

### Lab 2: Allow all traffic to an application

**Goal:** apply a policy that explicitly allows all ingress, and confirm it behaves like the no-policy default.

```bash
kubectl run web --image=nginx --labels=app=web --expose --port 80
kubectl apply -f manifests/web-allow-all.yaml
kubectl run test-wget --rm -i -t --image=alpine -- sh
# wget -qO- --timeout=2 http://web    # succeeds

kubectl delete po,service web
kubectl delete networkpolicy web-allow-all
```

`web-allow-all.yaml` selects `app: web` with a single `ingress: - {}` rule — an empty rule matches every possible source, so this is equivalent to no policy at all, but makes the "everything is allowed" intent explicit and auditable.

### Lab 3: Limit traffic to an application by label

**Goal:** allow ingress only from Pods carrying a specific label, and confirm Pods without it are refused.

```bash
kubectl run apiserver --image=nginx --labels app=bookstore,role=api --expose --port 80
kubectl apply -f manifests/api-allow.yaml

kubectl run test-wget --rm -i -t --image=alpine -- sh
# wget -qO- --timeout=2 http://apiserver           # times out: no app=bookstore label

kubectl run test-wget --rm -i -t --image=alpine --labels app=bookstore,role=frontend -- sh
# wget -qO- --timeout=2 http://apiserver           # succeeds: matches podSelector app=bookstore

kubectl delete po,service apiserver
kubectl delete networkpolicy api-allow
```

`api-allow.yaml` selects `app=bookstore,role=api` and only allows ingress from Pods labeled `app=bookstore` (any `role`) — so `test-wget` only succeeds once it carries that label too.

### Lab 4: Deny all non-whitelisted traffic to a namespace

**Goal:** apply a namespace-wide default-deny policy and confirm it blocks Pods from both inside and outside the namespace.

```bash
kubectl run apiserver --image=nginx --labels app=api --expose --port 80
kubectl apply -f manifests/default-deny-all.yaml

kubectl run test-wget --rm -i -t --image=alpine --labels app=bookstore -- sh
# wget -qO- --timeout=2 http://apiserver           # times out: same namespace, but selected by default-deny-all

kubectl create namespace other
kubectl run test-wget --rm -i -t --image=alpine --namespace=other -- sh
# wget -qO- --timeout=2 http://apiserver.default   # times out: different namespace, still denied

kubectl delete po,service apiserver
kubectl delete networkpolicy default-deny-all
kubectl delete namespace other
```

`default-deny-all.yaml` uses `podSelector: {}` — every Pod in the `default` namespace — with an empty `ingress: []`, making the entire namespace deny-by-default for ingress until more specific allow policies are added.

### Lab 5: Deny all traffic from other namespaces

**Goal:** allow traffic only from within the same namespace, blocking every other namespace.

```bash
kubectl create namespace secondary
kubectl run web --namespace secondary --image=nginx --labels=app=web --expose --port 80
kubectl apply -f manifests/deny-from-other-namespaces.yaml

kubectl run test-wget --namespace=default --rm -i -t --image=alpine -- sh
# wget -qO- --timeout=2 http://web.secondary       # times out: different namespace

kubectl run test-wget --namespace=secondary --rm -i -t --image=alpine -- sh
# wget -qO- --timeout=2 http://web.secondary       # succeeds: same namespace

kubectl delete po,service web -n secondary
kubectl delete networkpolicy deny-from-other-namespaces -n secondary
kubectl delete namespace secondary
```

`deny-from-other-namespaces.yaml` (applied in the `secondary` namespace) selects every Pod there (`podSelector: {}`) and allows ingress only `from: - podSelector: {}` — every Pod *in that same namespace* — implicitly excluding all other namespaces.

### Lab 6: Allow traffic to an application from all namespaces

**Goal:** allow ingress from any namespace, while still requiring the target Pod's label.

```bash
kubectl run web --image=nginx --namespace secondary --labels=app=web --expose --port 80
kubectl apply -f manifests/web-allow-all-namespaces.yaml

kubectl run test-wget --namespace=default --rm -i -t --image=alpine -- sh
# wget -qO- --timeout=2 http://web.secondary       # succeeds

kubectl delete po,service web -n secondary
kubectl delete networkpolicy web-allow-all-namespaces -n secondary
kubectl delete namespace secondary
```

`web-allow-all-namespaces.yaml` allows ingress `from: - namespaceSelector: {}` — every namespace, unconditionally — to Pods labeled `app: web` in `secondary`.

### Lab 7: Allow all traffic from one labeled namespace

**Goal:** allow ingress only from namespaces carrying a specific label (e.g. a `prod` environment), blocking others.

```bash
kubectl run web --image=nginx --labels=app=web --expose --port 80

kubectl create namespace dev
kubectl label namespace/dev purpose=testing

kubectl create namespace prod
kubectl label namespace/prod purpose=production

kubectl apply -f manifests/web-allow-prod.yaml

kubectl run test-wget --namespace=dev --rm -i -t --image=alpine -- sh
# wget -qO- --timeout=2 http://web.default         # times out: purpose=testing doesn't match

kubectl run test-wget --namespace=prod --rm -i -t --image=alpine -- sh
# wget -qO- --timeout=2 http://web.default         # succeeds: purpose=production matches

kubectl delete networkpolicy web-allow-prod
kubectl delete po,service web
kubectl delete namespace prod
kubectl delete namespace dev
```

`web-allow-prod.yaml` allows ingress `from: - namespaceSelector: matchLabels: purpose: production` — only namespaces labeled accordingly, regardless of the labels on the Pods inside them.

### Lab 8: Allow traffic from specific pods in another namespace

**Goal:** combine a `namespaceSelector` and a `podSelector` in the same rule, so both conditions must hold together.

```bash
kubectl run web --image=nginx --labels=app=web --expose --port 80
kubectl create namespace other
kubectl label namespace/other team=operations
kubectl apply -f manifests/web-allow-all-ns-monitoring.yaml

kubectl run test-wget --rm -i -t --image=alpine -- sh
# wget -qO- --timeout=2 http://web.default                                   # times out: no team/type match

kubectl run test-wget --labels type=monitoring --rm -i -t --image=alpine -- sh
# wget -qO- --timeout=2 http://web.default                                   # times out: right pod label, wrong namespace

kubectl run test-wget --namespace=other --rm -i -t --image=alpine -- sh
# wget -qO- --timeout=2 http://web.default                                   # times out: right namespace, wrong pod label

kubectl run test-wget --namespace=other --labels type=monitoring --rm -i -t --image=alpine -- sh
# wget -qO- --timeout=2 http://web.default                                   # succeeds: both match

kubectl delete networkpolicy web-allow-all-ns-monitoring
kubectl delete namespace other
kubectl delete po,service web
```

`web-allow-all-ns-monitoring.yaml` puts `namespaceSelector: matchLabels: team: operations` and `podSelector: matchLabels: type: monitoring` **inside the same rule entry**, so traffic is only allowed when the source Pod satisfies *both* conditions at once — the AND behavior described in [Key Concepts](#selecting-traffic-sources) above.

## Clean up

Each lab cleans up its own resources; if you stop partway through, remove anything left over with:

```bash
kubectl delete po,svc,networkpolicy --all -n default
kubectl delete namespace dev prod secondary other --ignore-not-found
```

## Further exercises

The `manifests/` directory also includes policies not covered step-by-step above, worth exploring on your own once you're comfortable with the labs:

- `default-deny-all-egress.yaml`, `foo-deny-egress.yaml` — deny-by-default for **egress** instead of ingress, using `policyTypes: [Egress]`.
- `foo-deny-external-egress.yaml` — allow only DNS (port 53) egress to any namespace, blocking everything else outbound.
- `api-allow-5000.yaml` — restrict ingress to a single port (`5000`) rather than every port on the Pod.
- `redis-allow-services.yaml` — allow ingress from several distinct `podSelector` roles at once (an OR across separate `from` entries).

## Further reading

- [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [Declare Network Policy](https://kubernetes.io/docs/tasks/administer-cluster/declare-network-policy/)
- [Cilium documentation](https://docs.cilium.io/) — the CNI plugin used in this course's clusters

---
Previous: [Pod Security](../pod-security/README.md) · Next: [RBAC](../rbac/README.md)
