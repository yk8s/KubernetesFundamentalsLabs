[//]: # (Confidential document - see ../CONFIDENTIAL.md)

# Module 5: Helm

*Part of the [Kubernetes Fundamentals Labs](../README.md) · Module 5 of 6 · Previous: [Configuration](../04-configuration/README.md) · Next: [Examples: WordPress](../06-examples/wordpress/README.md)*

## Overview

Helm is the de-facto package manager for Kubernetes. It packages a set of manifests — plus templating logic and default values — into a versioned, reusable unit called a **chart**, and manages the lifecycle of an installed chart (a **release**) as a whole. This module first covers Helm as a consumer (installing and managing charts from a public repository), then as an author (writing your own chart and templates).

## Objectives

By the end of this module, you will be able to:

- Install Helm and enable shell completion.
- Search for, inspect, install, upgrade, roll back, and uninstall a chart from a public repository.
- Unpack a chart archive and understand its directory layout.
- Scaffold a new chart with `helm create`, and validate it with `helm template` and `helm lint`.
- Use `if`/`else`, `default`, `required`, and named templates in your own chart templates.

## Prerequisites

- Completion of [Module 4: Configuration](../04-configuration/README.md).
- A running minikube cluster.
- Basic familiarity with YAML.

## Key concepts

### Charts, releases, and repositories

A **chart** is a directory (or packaged `.tgz` archive) containing a `Chart.yaml` manifest, a `values.yaml` file of default configuration, and a `templates/` directory of Kubernetes manifest templates. Installing a chart against a cluster creates a **release** — a named, versioned instance of that chart that Helm tracks so it can be upgraded, rolled back, or uninstalled as a unit. Charts are published to **repositories** (index files served over HTTP) that you add to your local Helm client with `helm repo add`.

### The Helm template language

Helm templates are Kubernetes manifests with [Go template](https://pkg.go.dev/text/template) actions embedded in them (`{{ ... }}`), rendered against the chart's values before being sent to the API server. Common building blocks include conditionals (`if`/`else if`/`else`), the `default` and `required` functions for guarding against missing values, the ternary-style `?:` idiom for compact conditionals, and **named templates** (defined in `_helpers.tpl` with `define`/`end`) for reusing snippets — such as a common set of labels — across multiple manifests.

## Labs

### Lab 1: Install Helm

**Goal:** install the Helm CLI and enable bash completion.

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

helm completion bash > /etc/bash_completion.d/helm
source ~/.bashrc
```

> Writing to `/etc/bash_completion.d/` typically requires `sudo`. If you don't have root access, write the completion script to a user-writable location and `source` it from your `~/.bashrc` instead.

### Lab 2: Chart lifecycle

**Goal:** search for a public chart, inspect it, install it, upgrade it with custom values, view its history, and roll back — using the Bitnami WordPress chart as an example.

```bash
helm search hub wordpress
helm search hub --max-col-width=100 wordpress
helm search hub --max-col-width=0 wordpress
helm search hub --list-repo-url wordpress
helm search hub wordpress -o json
helm search hub wordpress -o yaml

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm repo list
helm search repo wordpress
helm search repo --versions wordpress

helm show chart bitnami/wordpress
helm show readme bitnami/wordpress
helm show values bitnami/wordpress
helm show all bitnami/wordpress

helm install mywp bitnami/wordpress --set service.type=ClusterIP
kubectl port-forward --address 0.0.0.0 svc/mywp-wordpress 8888:80
helm list
helm status mywp
helm get values mywp
helm upgrade -f manifests/mywp-values.yaml mywp bitnami/wordpress
kubectl port-forward --address 0.0.0.0 svc/mywp-wordpress 8888:80
helm get values mywp
helm list
helm history mywp
helm rollback mywp 1
kubectl port-forward --address 0.0.0.0 svc/mywp-wordpress 8888:80
helm history mywp
kubectl get secret sh.helm.release.v1.mywp.v3 -o go-template='{{.data.release | base64decode | base64decode}}' | gzip -d | jq
helm uninstall mywp
```

Every Helm release is stored as a Secret in the release's namespace (`sh.helm.release.v1.<release>.v<revision>`), gzip-compressed and double base64-encoded — the last command decodes and inflates it so you can see the full rendered manifest Helm applied for that revision.

### Lab 3: Chart tree

**Goal:** download a chart archive and inspect its directory structure.

```bash
helm pull bitnami/wordpress --version 23.1.19
tar zxvf wordpress-23.1.19.tgz
sudo apt install tree
tree wordpress
```

> If a newer or older chart version is available in the repository, adjust `--version` accordingly — `helm search repo --versions wordpress` (from Lab 2) lists what's published.

### Lab 4: Your first chart

**Goal:** scaffold a new chart with `helm create`, then validate and install it.

```bash
helm create demo
tree demo
helm template demo
helm lint demo
helm install mydemo demo --debug --dry-run
helm install mydemo demo
```

`helm create` generates a fully working chart (a Deployment, Service, ServiceAccount, and supporting templates) that you can use as a reference for the structure expected of any chart. `helm template` renders the manifests locally without contacting the cluster; `--dry-run` on `helm install` goes one step further and validates the rendered manifests against the API server without actually creating anything.

### Lab 5: Templating — if / else if / else

**Goal:** in the `lab5` chart, write a ConfigMap template that branches on a value.

- Add a variable `var1` to `lab5/values.yaml`:

  ```yaml
  var1: 0.0
  ```

- Complete `lab5/templates/configmap.yaml` (named `cm-if-else`) so that:
  - if `var1 == 0` → `key: "zero"`
  - else if `var1 == 1` → `key: "one"`
  - else → `key: "other"`

Use `helm template lab5` to check the rendered output for each value of `var1` before installing.

### Lab 6: Templating — if / else if / else with `fail`

**Goal:** repeat Lab 5 in the `lab6` chart (ConfigMap `cm-if-else-fail`), but this time make invalid input a hard error instead of a silent default:

- if `var1 == 0` → `key: "zero"`
- else if `var1 == 1` → `key: "one"`
- else → fail the template render with `fail "Invalid value for var1"`

`fail` stops `helm template`/`helm install` immediately with the message you provide — useful for catching misconfiguration early instead of deploying something broken.

### Lab 7: Templating — `default` and `required`

**Goal:** in the `lab7` chart, write a ConfigMap template (`cm-ternary-default-required`) that demonstrates three ways of handling a value from `values.yaml`:

- `key1`, using the **ternary** idiom (`{{ .Values.var2 | eq 1 | ternary "yes" "no" }}` or equivalent)
- `key2`, using **`default`** to substitute a fallback when a value is unset
- `key3`, using **`required`** to fail the render when a value is missing

Add `var2` to `lab7/values.yaml`:

```yaml
var2: 1
```

### Lab 8: Named templates

**Goal:** define a reusable label snippet in `lab8/templates/_helpers.tpl`, and use it from both a new ConfigMap and the existing Service template.

The chart's `_helpers.tpl` already defines two variants to compare:

```gotemplate
{{- define "lab12.mylabels.v1" -}}
labels:
  env: {{ .Values.env }}
  app: {{ .Release.Name }}
{{- end }}
{{- define "lab12.mylabels.v2" -}}
env: {{ .Values.env }}
app: {{ .Release.Name }}
{{- end }}
```

`v1` renders the full `labels:` block, so it can be `include`d directly under a resource's `metadata:`. `v2` renders only the key/value pairs, so it needs to be nested under a `labels:` key you write yourself — useful when a template needs to merge those labels with others. Update `lab8/templates/service.yaml` (currently a bare Service with a `## add labels:` placeholder) to include one of these named templates, then add a new ConfigMap template that uses the other.

### Lab 9: Capstone chart

**Goal:** apply everything from this module to a chart of your own.

- Scaffold a new chart (`helm create`, as in Lab 4).
- Add `_helpers.tpl` templates implementing at least two best-practice patterns, for example:
  - A named template for the Deployment's `strategy` (rolling update configuration).
  - A named template for computing `replicaCount` (e.g. falling back to a default, or failing if unset).
- Validate with `helm lint` and `helm template` before installing.

## Clean up

```bash
helm uninstall mywp mydemo 2>/dev/null
kubectl delete pvc --all
```

## Further reading

- [Helm documentation](https://helm.sh/docs/)
- [Chart Template Guide](https://helm.sh/docs/chart_template_guide/getting_started/)
- [Built-in Objects](https://helm.sh/docs/chart_template_guide/builtin_objects/)
- [Named Templates](https://helm.sh/docs/chart_template_guide/named_templates/)
- [Artifact Hub](https://artifacthub.io/) (the successor to Helm Hub, searched by `helm search hub`)

---
Previous: [Module 4: Configuration](../04-configuration/README.md) · Next: [Module 6: Examples — WordPress](../06-examples/wordpress/README.md)
