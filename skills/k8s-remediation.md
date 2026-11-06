# Skill: Kubernetes Security Remediation

## Trigger
When a K8s manifest fails security linting, contains `runAsRoot: true`,
is missing a `securityContext`, or has no resource limits/requests.

## Protocol
1. Parse the invalid deployment manifest and identify all policy violations.
2. Apply `securityContext` blocks:
   - `runAsNonRoot: true`
   - `runAsUser: 1000`
   - `allowPrivilegeEscalation: false`
3. Inject `resources.requests` and `resources.limits` for CPU and memory
   if missing. Use these conservative defaults:
   - CPU request: 100m, limit: 500m
   - Memory request: 128Mi, limit: 256Mi
4. Fix the `livenessProbe` to point to `/healthz` on the correct port.
5. Add a `readinessProbe` if missing (same endpoint, different timing).
6. Replace `latest` image tags with a pinned version if known, or flag for human input.
7. Trigger the @Validator agent to run `kubectl apply --dry-run=client` and `kubeconform -strict`.
8. Surface a diff of all changes for human review. Do not open a PR automatically.

## Defaults
These values are safe starting points. Override per-service if the team
has documented requirements elsewhere.

| Resource | Request | Limit |
|----------|---------|-------|
| CPU      | 100m    | 500m  |
| Memory   | 128Mi   | 256Mi |
