# Nibble Plan Review Implementation Plan

> **For agentic workers:** Use this plan task-by-task. Steps use checkbox syntax for tracking.

**Goal:** Add a standalone skill that reviews Nibble feature plans and saves actionable feedback to Markdown.

**Architecture:** Add one self-contained `skills/nibble-plan-review/SKILL.md`. Register it in the existing installer and document its optional position, report path, install command, and repository layout in the README. It does not alter `nibble-plan` or gate the feature loop.

**Tech Stack:** Markdown skill instructions, Bash installer, README.

**Spec:** `docs/superpowers/specs/2026-10-26-nibble-plan-review-design.md`

## Global Constraints

- The skill is standalone and optional after `nibble-plan`.
- It reviews but does not edit the plan or code.
- Its report path is `running-docs/nibble-plan-review.md` in the target repository.
- It replaces only its own prior report.
- No new dependency.

## Review Focus

- Missing plan file: report the precondition clearly, set the verdict to `Revise`, and point to `nibble-plan`.
- Plan does not fit repository structure: cite the relevant code or module evidence.
- Slice is too broad or not end-to-end: identify the smallest needed adjustment.
- Wiring or conventions are missing: name the affected layer and sibling pattern.
- Verification is vague or deferred work hides a requirement: request concrete corrections.

---

### Task 1: Add the plan review skill

**Files:**
- Create: `skills/nibble-plan-review/SKILL.md`

**Interfaces:**
- Consumes: `.nibble/nibble-plan.md` and relevant repository files named by or needed to assess the plan.
- Produces: `running-docs/nibble-plan-review.md` with a `Ready` or `Revise` verdict and actionable, evidence-based feedback.

- [x] Write the skill instructions, including the no-plan case, review criteria, evidence requirements, no-edit boundary, and overwrite behavior for its own report.
- [x] Confirm frontmatter name and folder name both use `nibble-plan-review`.

### Task 2: Make the skill installable and discoverable

**Files:**
- Modify: `install.sh`
- Modify: `README.md`

- [x] Add `nibble-plan-review` once to the installer's skill list.
- [x] Mark it as an optional review after `nibble-plan` in the feature loop.
- [x] Add its report to the reviewable reports table and its copy command and repository-layout entry.
- [x] Run `git diff --check` and inspect the final diff for consistent references.

**Review focus verification:** Confirm the skill states what to do when the input plan is absent, recommendations cite repo evidence, review remains read-only, and generated feedback is written only to its designated report file.
