# ArgoCD Hub Management Repo
The central control plane for the Hub-and-Spoke GitOps model.

## Role in GitOps (The "How")
This repo defines:
- `AppProjects`: Who can deploy where.
- `Applications`: The link between the App Repo and the Config Repo.

## Architecture
The Hub manages remote clusters (laura-app-prod, laura-app-stg) via integrated secrets.
