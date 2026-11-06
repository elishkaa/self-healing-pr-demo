# Demo Guide: Self-Healing PR

Live terminal demo for engineers. One argument: a single Claude prompt replaces
manual CI triage, patching, and validation — under explicit guardrails.

**Total time: ~9 min**

---

## Reset Before Each Run

```bash
git reset --hard demo-start
```

---

## Stage 1 — The Setup (~2 min)

Show that this isn't a toy — there's a defined agent team, permissions, and a skill playbook.

```bash
cat AGENTS.md
cat skills/k8s-remediation.md
```

**Talking points:**
- Two agents: @Architect (reasons, patches) and @Validator (verifies, read-only)
- Guardrails are explicit: no auto-push to main, diff must surface for human review
- The skill is the playbook — the agent doesn't improvise, it follows a protocol

---

## Stage 2 — The Crime Scene (~2 min)

Make the problem concrete. Show the broken manifest, then prove it fails CI.

```bash
cat k8s/deployment.yaml
bash scripts/validate.sh
```

**Talking points:**
- A junior dev pushed this — 5 violations: runs as root, no limits, wrong probe, no readiness, `latest` tag
- This is what CI sees — deploy is blocked on every push to main
- Manual fix means: read the logs, cross-reference K8s docs, write the patch, re-run CI

---

## Stage 3 — The Agent Run (~3 min)

The core moment. Paste one prompt, watch the full cycle play out.

```
/fix-pipeline Review the latest failing CI log, patch the K8s deployment file
according to our security skill rules, and verify the fix locally.
```

**Watch live:**
1. @Architect loads `skills/k8s-remediation.md`
2. Runs `validate.sh` — reproduces all 5 failures
3. Patches `k8s/deployment.yaml` — edits happen visibly in the editor
4. @Validator runs `validate.sh` again — all green
5. Surfaces the diff — **stops and waits for human approval**

**Talking points:**
- It didn't guess — it followed the skill protocol step by step
- @Validator is a separate check — it verifies, it doesn't reason
- It stopped. No PR was opened. The guardrail in AGENTS.md was respected.

---

## Stage 4 — The Proof (~1 min)

Show the audit trail.

```bash
git diff k8s/deployment.yaml
git log --oneline
```

**Talking points:**
- Every change is attributable — the commit message cites the skill
- A human still approves before anything touches the cluster
- This is the diff a senior engineer would write — because the skill encodes their knowledge

---

## Stage 5 — The Point (~1 min)

> "This moves the conversation from 'AI can write code' to
> 'AI can operate your engineering ecosystem under strict guardrails.'"

**Discussion questions:**
- What other runbooks in your team could become skills?
- Where in your pipeline does the most manual triage happen today?

---

## Commit the Fix

After the demo, commit the agent's patch:

```bash
git add k8s/deployment.yaml
git commit -m "fix: remediate K8s security violations per k8s-remediation skill"
```

Then reset for the next run:

```bash
git reset --hard demo-start
```

---

## Timing Summary

| Stage | Content | Time |
|-------|---------|------|
| 1 | Setup — AGENTS.md + skill | ~2 min |
| 2 | Crime scene — broken manifest + red CI | ~2 min |
| 3 | Agent run — live fix cycle | ~3 min |
| 4 | Proof — diff + git log | ~1 min |
| 5 | The point — discussion | ~1 min |
| **Total** | | **~9 min** |
