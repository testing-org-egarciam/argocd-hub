#!/bin/bash

# Usage: ./generate-apps.sh <app-name> <branch>
# Example: ./generate-apps.sh laura-app feat/application-sets

APP_NAME=$1
BRANCH=${2:-main}

if [ -z "$APP_NAME" ]; then
    echo "Usage: $0 <app-name> [branch]"
    exit 1
fi

# Configuration
CONFIG_REPO_URL="https://raw.githubusercontent.com/testing-org-egarciam/gitops-config/${BRANCH}"
HUB_CONTEXT="kind-argocd-hub"

echo "🚀 Starting Application Generator for app: $APP_NAME (Branch: $BRANCH)"

# Find all cluster yaml files in the config repo
# For this PoC, we know the clusters we have: prod and stg.
CLUSTERS=("prod" "stg")

for CLUSTER in "${CLUSTERS[@]}"; do
    echo "📦 Generating manifest for $CLUSTER..."
    
    # Create a temporary manifest
    cat <<MANIFEST > "tmp-${APP_NAME}-${CLUSTER}.yaml"
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${APP_NAME}-${CLUSTER}
  namespace: argocd
spec:
  project: ${APP_NAME}-project
  source:
    repoURL: https://github.com/testing-org-egarciam/nginx-app.git
    targetRevision: HEAD
    path: charts/${APP_NAME}
    helm:
      valueFiles:
        - "${CONFIG_REPO_URL}/values/${APP_NAME}/clusters/${CLUSTER}.yaml"
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
MANIFEST

    # Apply the manifest
    kubectl --context $HUB_CONTEXT apply -f "tmp-${APP_NAME}-${CLUSTER}.yaml"
    
    # Cleanup
    rm "tmp-${APP_NAME}-${CLUSTER}.yaml"
done

echo "✅ Successfully deployed all applications for $APP_NAME."
