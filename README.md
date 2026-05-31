# The Self-Healing PR — An Antigravity 2.0 + Claude Demo

## What This Is

A demo project showing how Google Antigravity + Claude can autonomously diagnose a broken CI pipeline, patch a misconfigured Kubernetes deployment, and validate the fix — all from a single prompt.

## The Scenario

A junior developer pushed a K8s deployment with security flaws. The CI pipeline fails on every push to main. Instead of manual triage — reading logs, cross-referencing K8s policy docs, writing the patch, re-running CI — Antigravity's agent mesh handles it end to end.

## Project Structure

| File | Role |
|------|------|
| `AGENTS.md` | Defines the AI agent team (@Architect, @Validator) and their permissions and guardrails |
| `skills/k8s-remediation.md` | The playbook loaded automatically when a K8s security issue is detected |
| `k8s/deployment.yaml` | The intentionally broken manifest — missing securityContext, resource limits, and a valid health probe |
| `.github/workflows/deploy.yml` | The CI pipeline that catches the problem; correct by design, blocked by the bad manifest |
| `scripts/validate.sh` | Local validation script that mirrors what the @Validator agent runs in CI |
| `app/` | The minimal Node.js service being deployed (Express, port 8080, `/healthz` endpoint) |

## How to Run the Demo

1. Open this folder in Antigravity.
2. Run the following prompt:

   ```
   /fix-pipeline Review the latest failing CI log, patch the K8s deployment file
   according to our security skill rules, and verify the fix locally.
   ```

3. Watch the agent team work: @Architect plans and patches, @Validator runs the checks, both stop and surface a diff for your approval before any PR is opened.

## The Point

This moves the conversation from "AI can write code" to "AI can operate your engineering ecosystem under strict guardrails."

The agents don't just fix the file — they follow a defined skill, respect access boundaries set in `AGENTS.md`, and require human sign-off before touching a protected branch. That is the difference between a coding assistant and an autonomous engineering operator.
