[//]: # (Confidential document - see ../../CONFIDENTIAL.md)

# Security: Trivy

*Part of the [Kubernetes Advanced Labs](../../README.md) · Module 4 (final) · Previous: [Kyverno](../kyverno/README.md)*

## Overview

This closing module shifts from *enforcing* policy at admission time (Kyverno) to *scanning* what's already running — finding known vulnerabilities, misconfigurations, exposed secrets, and license issues across a cluster or a single image. Trivy is the scanner used for this: a single CLI that targets everything from a container image to a whole live cluster.

## Objectives

By the end of this module, you will be able to:

- Explain what Trivy can scan (targets) and what it looks for (scanners).
- Run a cluster-wide scan and read its summary report.
- Scope a scan to a namespace, a resource kind, or a specific scanner.
- Scan a container image for vulnerabilities, misconfigurations, and license issues, and generate an SBOM.

## Prerequisites

- Completion of [Kyverno](../kyverno/README.md).
- A running minikube cluster with the [Trivy CLI](https://aquasecurity.github.io/trivy/latest/getting-started/installation/) installed locally.

This module has no `manifests/` directory — every lab runs `trivy` directly against your cluster or against public images, with no objects to apply beforehand.

## Key concepts

### Targets and scanners

Trivy separates **what** it scans (a target) from **what it looks for** (a scanner), and most commands combine one of each:

**Targets** (what Trivy can scan):

- Container image
- Filesystem
- Git repository (remote)
- Virtual machine image
- Kubernetes (cluster or specific resources)
- AWS

**Scanners** (what Trivy can find there):

- OS packages and software dependencies in use (SBOM)
- Known vulnerabilities (CVEs)
- Infrastructure-as-code issues and misconfigurations
- Sensitive information and secrets
- Software licenses

### Useful flags

```text
trivy k8s [flags] { cluster | all | specific resources like kubectl, e.g. pods, pod/NAME }

  --scanners      which scanners to run (default "vuln,config,secret,rbac")
  --compliance    a compliance framework to report against
                  (k8s-nsa, k8s-cis, k8s-pss-baseline, k8s-pss-restricted)
  --format        output format (table, json, template, sarif, cyclonedx,
                   spdx, spdx-json, github, cosign-vuln) (default "table")
  --severity      minimum severities to include
                  (default "UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL")
  --vuln-type     os, library, or both (default "os,library")
  --components    which parts of the cluster to include
                  (default [workload,infra])
  --parallel      concurrent scans, between 1 and 20 (default 5)
```

## Labs

### Lab 1: Scan the whole cluster

**Goal:** run a cluster-wide scan, get a summary, and try a few of the flags above.

```bash
trivy k8s --report summary
trivy k8s --report summary -f json > k8s.json

trivy k8s --severity=CRITICAL --report=all
trivy k8s --scanners vuln --report all
trivy k8s --scanners=secret --report=summary
trivy k8s --scanners=misconfig --report=summary
trivy k8s --report summary --skip-images
trivy k8s --report summary --exclude-kinds node,pod

trivy k8s --compliance k8s-pss-baseline --report summary
trivy k8s --compliance k8s-cis-1.23 --report summary
```

`--report summary` gives you a one-line-per-resource overview; `--report all` (or writing to JSON with `-f json`) gives you the full, per-finding detail. `--compliance` reports the same findings mapped against a named framework — the Pod Security Standards baseline in this example — instead of a flat list.

### Lab 2: Scope a scan to a namespace or resource kind

**Goal:** narrow a scan to `kube-system`, then to specific resource kinds within it.

```bash
trivy k8s --include-namespaces kube-system --severity=CRITICAL --report summary
trivy k8s --include-kinds pod --include-namespaces kube-system --report summary
trivy k8s --include-kinds configmap --include-namespaces kube-system --report summary
```

### Lab 3: Run individual scanners

**Goal:** run the `config` scanner in isolation, at different report verbosities.

```bash
trivy k8s --report summary --scanners=config
trivy k8s --report all --scanners=config
```

The `config` scanner looks for infrastructure-as-code misconfigurations (things like missing resource limits or overly permissive RBAC) rather than known CVEs — compare its output to the `vuln` and `secret` scanners you already ran in Lab 1.

### Lab 4: Scan a container image

**Goal:** scan a standalone image for vulnerabilities, misconfigurations, and license issues, check it against a compliance framework, and generate a software bill of materials (SBOM).

```bash
trivy image python:3.4-alpine

trivy image --scanners vuln centos:7
trivy image --scanners misconfig centos:7
trivy image --scanners license centos:7
trivy image --compliance docker-cis-1.6.0 centos:7
trivy image --format spdx-json --output result.json alpine:3.15
```

The first command uses Trivy's defaults (`vuln,secret`) against a deliberately old image (`python:3.4-alpine`) to produce a non-trivial vulnerability list; the last generates an SPDX-format SBOM to a file instead of printing a human-readable table — useful as an artifact to attach to a build or a release.

## Further reading

- [Trivy documentation](https://aquasecurity.github.io/trivy/latest/)
- [Trivy Kubernetes scanning](https://aquasecurity.github.io/trivy/latest/docs/target/kubernetes/)
- [Trivy compliance reports](https://aquasecurity.github.io/trivy/latest/docs/compliance/)
- [SPDX](https://spdx.dev/) — the SBOM format generated in Lab 4

---
This is the final module of the [Kubernetes Advanced Labs](../../README.md). Previous: [Kyverno](../kyverno/README.md) · Back to: [Kubernetes Advanced Labs](../../README.md)
