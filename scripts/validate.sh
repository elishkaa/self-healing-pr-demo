#!/usr/bin/env bash

MANIFEST="k8s/deployment.yaml"
GREEN='\033[0;32m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

FAILURES=()

pass() { echo -e "${GREEN}PASS${RESET}  $1"; }
fail() { echo -e "${RED}FAIL${RESET}  $1"; FAILURES+=("$1"); }

echo -e "\n${BOLD}@Validator — K8s Manifest Check${RESET}"
echo -e "Manifest: ${MANIFEST}\n"

# --- kubeval ---
if ! command -v kubeval &>/dev/null; then
  echo -e "${RED}SKIP${RESET}  kubeval not installed — run: brew install kubeval"
else
  if kubeval "$MANIFEST" &>/dev/null; then
    pass "kubeval schema validation"
  else
    fail "kubeval schema validation"
    kubeval "$MANIFEST"
  fi
fi

# --- kubectl dry-run ---
if ! command -v kubectl &>/dev/null; then
  echo -e "${RED}SKIP${RESET}  kubectl not installed — dry-run skipped"
else
  if kubectl apply --dry-run=client -f "$MANIFEST" &>/dev/null; then
    pass "kubectl apply --dry-run=client"
  else
    fail "kubectl apply --dry-run=client"
  fi
fi

# --- Security checks ---
if grep -q "runAsNonRoot" "$MANIFEST"; then
  pass "securityContext: runAsNonRoot is set"
else
  fail "securityContext: runAsNonRoot missing — container may run as root"
fi

if grep -q "resources:" "$MANIFEST"; then
  pass "resource requests/limits are defined"
else
  fail "resource requests/limits missing — pod can consume unlimited cluster resources"
fi

if grep -qE "image:.*:latest" "$MANIFEST"; then
  fail "image tag is 'latest' — pin to a specific version"
else
  pass "image tag is pinned"
fi

if grep -q "readinessProbe" "$MANIFEST"; then
  pass "readinessProbe is defined"
else
  fail "readinessProbe missing — service may receive traffic before ready"
fi

if grep -A3 "livenessProbe:" "$MANIFEST" | grep -q 'path: /healthz'; then
  pass "livenessProbe path is /healthz"
else
  fail "livenessProbe path is not /healthz"
fi

# --- Summary ---
echo ""
if [ ${#FAILURES[@]} -eq 0 ]; then
  echo -e "${GREEN}${BOLD}All checks passed.${RESET}"
  exit 0
else
  echo -e "${RED}${BOLD}${#FAILURES[@]} check(s) failed:${RESET}"
  for f in "${FAILURES[@]}"; do
    echo -e "  ${RED}•${RESET} $f"
  done
  exit 1
fi
