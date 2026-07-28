#!/usr/bin/env bash
# Bootstrap local Kind cluster and Vault dev mode.
# Requires: docker, kind, kubectl, helm, terraform (for platform apply)
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
KIND_CLUSTER_NAME="${KIND_CLUSTER_NAME:-pe-copilot}"
VAULT_NAMESPACE="${VAULT_NAMESPACE:-vault}"
VAULT_RELEASE="${VAULT_RELEASE:-vault}"
STATE_FILE="${ROOT_DIR}/.platform-state"

log() { echo "[bootstrap] $*"; }
die() { echo "[bootstrap] ERROR: $*" >&2; exit 1; }

ensure_port_forward() {
  if curl -sf "${VAULT_ADDR:-http://127.0.0.1:8200}/v1/sys/health" >/dev/null 2>&1; then
    return 0
  fi
  log "Restarting Vault port-forward..."
  nohup kubectl port-forward svc/"${VAULT_RELEASE}" 8200:8200 \
    -n "${VAULT_NAMESPACE}" \
    --context "kind-${KIND_CLUSTER_NAME}" \
    >> "${ROOT_DIR}/.vault-port-forward.log" 2>&1 &
  PF_PID=$!
  disown "${PF_PID}" 2>/dev/null || true
  for i in $(seq 1 15); do
    if curl -sf "${VAULT_ADDR:-http://127.0.0.1:8200}/v1/sys/health" >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  die "Vault port-forward failed to become reachable"
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

require_cmd kind
require_cmd kubectl
require_cmd helm
require_cmd docker

if ! docker info >/dev/null 2>&1; then
  die "Docker is not running. Start Docker and retry."
fi

# --- Kind cluster ---
if kind get clusters 2>/dev/null | grep -qx "${KIND_CLUSTER_NAME}"; then
  log "Kind cluster '${KIND_CLUSTER_NAME}' already exists"
else
  log "Creating Kind cluster '${KIND_CLUSTER_NAME}'..."
  kind create cluster --config "${ROOT_DIR}/platform/kind/cluster.yaml" --name "${KIND_CLUSTER_NAME}"
fi

kubectl cluster-info --context "kind-${KIND_CLUSTER_NAME}" >/dev/null
log "Kind cluster ready"

# --- Vault via Helm ---
helm repo add hashicorp https://helm.releases.hashicorp.com 2>/dev/null || true
helm repo update hashicorp

if helm status "${VAULT_RELEASE}" -n "${VAULT_NAMESPACE}" --kube-context "kind-${KIND_CLUSTER_NAME}" >/dev/null 2>&1; then
  log "Vault Helm release already installed"
else
  log "Installing Vault (dev mode)..."
  helm install "${VAULT_RELEASE}" hashicorp/vault \
    --namespace "${VAULT_NAMESPACE}" \
    --create-namespace \
    --kube-context "kind-${KIND_CLUSTER_NAME}" \
    --values "${ROOT_DIR}/platform/helm/vault-values-dev.yaml" \
    --wait --timeout 5m
fi

log "Waiting for Vault pod..."
kubectl wait --for=condition=ready pod \
  -l app.kubernetes.io/name=vault \
  -n "${VAULT_NAMESPACE}" \
  --context "kind-${KIND_CLUSTER_NAME}" \
  --timeout=120s

# --- Port-forward Vault to localhost ---
PF_PID=""
if [ -f "${STATE_FILE}" ]; then
  # shellcheck disable=SC1090
  source "${STATE_FILE}" 2>/dev/null || true
fi

if [ -n "${PF_PID:-}" ] && kill -0 "${PF_PID}" 2>/dev/null; then
  log "Vault port-forward already running (pid ${PF_PID})"
else
  log "Starting Vault port-forward on localhost:8200..."
  nohup kubectl port-forward svc/"${VAULT_RELEASE}" 8200:8200 \
    -n "${VAULT_NAMESPACE}" \
    --context "kind-${KIND_CLUSTER_NAME}" \
    >> "${ROOT_DIR}/.vault-port-forward.log" 2>&1 &
  PF_PID=$!
  disown "${PF_PID}" 2>/dev/null || true
  sleep 2
fi

export VAULT_ADDR="${VAULT_ADDR:-http://127.0.0.1:8200}"
export VAULT_TOKEN="${VAULT_TOKEN:-root}"

ensure_port_forward
log "Vault API reachable at ${VAULT_ADDR}"

# --- Service account token for Kubernetes auth (K8s 1.24+ does not auto-create) ---
if ! kubectl get secret vault-sa-token -n "${VAULT_NAMESPACE}" \
  --context "kind-${KIND_CLUSTER_NAME}" >/dev/null 2>&1; then
  log "Creating Vault service account token secret..."
  kubectl apply --context "kind-${KIND_CLUSTER_NAME}" -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: vault-sa-token
  namespace: ${VAULT_NAMESPACE}
  annotations:
    kubernetes.io/service-account.name: ${VAULT_RELEASE}
type: kubernetes.io/service-account-token
EOF
  sleep 3
fi

# --- Write state file ---
cat > "${STATE_FILE}" <<EOF
KIND_CLUSTER_NAME=${KIND_CLUSTER_NAME}
VAULT_ADDR=${VAULT_ADDR}
VAULT_TOKEN=${VAULT_TOKEN}
PF_PID=${PF_PID}
KUBECONFIG_CONTEXT=kind-${KIND_CLUSTER_NAME}
EOF

log "Bootstrap complete."
log "  VAULT_ADDR=${VAULT_ADDR}"
log "  VAULT_TOKEN=${VAULT_TOKEN}"
log "  Context: kind-${KIND_CLUSTER_NAME}"
log ""
log "Next: make platform-apply   # configure Kubernetes auth via Terraform"
