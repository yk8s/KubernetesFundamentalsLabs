[//]: # (Confidential document - see ../../CONFIDENTIAL.md)

# Services & Networking: Ingress

*Part of the [Kubernetes Advanced Labs](../../README.md) · Module 3 · Previous: [Services](../services/README.md) · Next: [Security: Pod Security](../../04-security/pod-security/README.md)*

## Overview

A `LoadBalancer` Service (see the [previous module](../services/README.md)) gives one external IP per Service — fine for a handful of services, but expensive and hard to manage once you have dozens of HTTP(S) applications to expose. Ingress solves this by routing HTTP and HTTPS traffic from a single entry point to many internal Services, based on rules you define (hostname, path, etc.).

## Objectives

By the end of this module, you will be able to:

- Explain the relationship between an Ingress **resource** (the routing rules) and an Ingress **controller** (the component that implements them).
- Enable an Ingress controller on minikube.
- Create an Ingress resource that routes a hostname to a Service, and reach it from your local machine.

## Prerequisites

- Completion of [Services](../services/README.md) — Ingress routes to Services, not directly to Pods.
- A running minikube cluster.

## Key concepts

### Ingress resources and controllers

An **Ingress resource** declares the routing rules you want (for example, "requests for `demo.localdev.me` go to the `demo` Service on port 80"). On its own, an Ingress resource does nothing — it needs an **Ingress controller** running in the cluster to watch for Ingress resources and actually implement the routing, typically as a reverse proxy (NGINX, Traefik, HAProxy, a cloud load balancer, …). Kubernetes ships the resource type but not a default controller, so you must install one — this lab uses minikube's `ingress` addon, which deploys `ingress-nginx`.

## Lab

### Lab 1: Route a hostname to a Service

**Goal:** enable the NGINX Ingress controller, expose a demo Deployment, create an Ingress resource for it, and reach it via its hostname from your local machine.

```bash
minikube addons enable ingress
kubectl get all -n ingress-nginx
```

Create a demo Deployment and expose it internally with a ClusterIP Service:

```bash
kubectl create deployment demo --image=httpd --port=80
kubectl expose deployment demo
```

Create an Ingress resource that routes all paths under `demo.localdev.me` to that Service:

```bash
kubectl create ingress demo-localhost --class=nginx \
  --rule="demo.localdev.me/*=demo:80"
kubectl get ing -o yaml
```

`localdev.me` is a public domain that always resolves to `127.0.0.1`, which is convenient for local Ingress testing — but since the Ingress controller itself isn't bound to your host's port 80/443 on every setup, port-forward its Service and use `curl --resolve` to reach it without needing real DNS or `/etc/hosts` changes:

```bash
kubectl port-forward --namespace=ingress-nginx service/ingress-nginx-controller 8080:80

curl --resolve demo.localdev.me:8080:127.0.0.1 http://demo.localdev.me:8080
```

`--resolve` tells `curl` to treat `demo.localdev.me:8080` as `127.0.0.1` without a DNS lookup, while still sending the `Host: demo.localdev.me` header the Ingress controller uses to match the rule.

## Clean up

```bash
kubectl delete deployment demo
kubectl delete svc demo
kubectl delete ing demo-localhost
```

## Further reading

- [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [Ingress Controllers](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)
- [ingress-nginx documentation](https://kubernetes.github.io/ingress-nginx/)

---
Previous: [Services](../services/README.md) · Next: [Security: Pod Security](../../04-security/pod-security/README.md)
