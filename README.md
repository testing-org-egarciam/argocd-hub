# ArgoCD Hub Management Repository

This repository serves as the **"How"** in the GitOps model: it defines the **governance, deployment logic, and target mapping** for the Hub-and-Spoke ArgoCD control plane.

## 📦 Repository Purpose

In the **Hub-and-Spoke Architecture**:
- **Hub Cluster**: Runs the ArgoCD control plane (`argocd-hub`).
- **Spoke Clusters**: Target Kubernetes clusters where workloads are deployed (`laura-app-prod`, `laura-app-stg`, `printolito-prod`).
- **Git Repos**: 
  - **Application Source Repos** (`laura-app`, `printolito`): Contains the *what* — source code and base Helm charts.
  - **Environment Config Repo** (`gitops-config`): Contains the *where* — environment-specific values.
  - **This Repo** (`argocd-hub`): Contains the *how* — ApplicationSets, AppProjects, and routing logic.

## 📁 Contents

| File | Description |
| :--- | :--- |
| `*-project.yaml` | Defines `AppProject` resources (e.g., `laura-project`, `printolito-project`) that scope which source repos and destinations are allowed for each tenant. |
| `appset-*.yaml` | `ApplicationSet` resources (e.g., `appset-laura-app.yaml`, `appset-printolito.yaml`) that dynamically discover clusters and render applications using List Generators mapping API IPs to environments. |
| `README.md` | This file. |

## 🔗 How It Works

1. **ArgoCD Hub** watches this repository for changes.
2. When an `ApplicationSet` is applied, ArgoCD:
   - Uses the List Generator to find target cluster IPs and environment names (`prod`, `stg`).
   - Fetches the base Helm chart from the **Application Source Repo**.
   - Retrieves environment-specific overrides from the **Environment Config Repo**.
   - Renders the final manifests and deploys them to the spoke clusters.

## 🛡️ Governance & Isolation

- **AppProjects** restrict:
  - **Source Repos**: Only approved repositories are allowed for specific apps.
  - **Destinations**: Deployments are limited strictly to the designated spoke clusters and app-owned namespaces.
- This prevents a misconfigured application from pulling charts from unapproved repositories or deploying to clusters outside its scope.

## Namespace Convention

Workloads are deployed to a namespace named after the application repository by default:

- `laura-app` deploys to `laura-app`.
- `nginx-app` deploys to `nginx-app`.
- `printolito` deploys to `printolito-app`.

Do not deploy applications to `default` unless the exception is explicitly documented in the ApplicationSet and AppProject.

## 🚀 How to Add a New Application

1. **Create** the source repo (e.g., `new-app`) with a Helm chart.
2. **Add** environment values to `gitops-config/values/new-app/<env>.yaml`.
3. **Add** to this repo:
   - A new `new-app-project.yaml` configuring repo/cluster access.
   - A new `appset-new-app.yaml` using a List Generator to map your target clusters.
4. Commit and push. ArgoCD will automatically generate the Applications and sync them.
