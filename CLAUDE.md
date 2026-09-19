# Project: dsSupportClient

## WHAT THIS REPO IS
A DataSHIELD client-side package (`nfdi4health/dsSupportClient`) — a wrapper
around other client-side DataSHIELD packages, with **no server-side
counterpart of its own** (some DataSHIELD client packages have a matching
server package; this one deliberately doesn't). Currently being used as the
live test bed for rolling out `package-workflows`'s reusable CI/release/
doc-assist workflows.

## CALLER WORKFLOWS IN THIS REPO

- `.github/workflows/release.yml` — calls `package-workflows`'s
  `release.yml`. Trigger: `pull_request` into `main`, gated behind an R CMD
  check job (`run-tests`), branching to merge+release on success or an issue
  on failure. Working, tested end to end.
- `.github/workflows/check.yml` — calls `package-workflows`'s `R-CMD-Check.yml`.
  Trigger: `pull_request` into `dev` only (not `main` — avoids double-running
  since `release.yml`'s gate already covers the dev→main path), plus a
  monthly-ish `schedule` and `workflow_dispatch`. Includes a
  `workflow-keepalive` job so the schedule doesn't get disabled after 60 days
  of inactivity. Working.
- `.github/workflows/docs-suggest.yml` — calls `package-workflows`'s
  `roxygen-suggest.yml` in `changed` mode. Trigger: `pull_request` into `dev`.
  Sets `datashield: true`, `datashield-type: client`.
- `.github/workflows/docs-suggest-full.yml` — same reusable workflow, `scan-mode:
  all`. Trigger: monthly `schedule` + `workflow_dispatch`. **Never actually
  tested yet** — built but not run.

Both doc-suggest callers currently use `anthropic-federation-rule-id:
fdrl_01XXW9s2iFKveZyKKizcggit` — this repo's specific federation rule in the
Claude Console (subject-prefix + `job_workflow_ref` claim match).

## DESIGN DECISIONS SPECIFIC TO THIS REPO'S WORKFLOW
- PRs only ever land in `dev` via PR, never direct push — a deliberate
  convention so every future check (doc-assist, anything added later) has
  exactly one place to hook into. **Not yet enforced** — branch protection on
  `dev` via the Rulesets API is still on the to-do list; until then this is a
  convention, not a guarantee.
- The whole reusable-workflow ecosystem is being validated here first, on a
  disposable test PR, before being rolled out to real packages.

## CURRENT TEST: PR #4 (`feat/fs/workflows` → `dev`)
This PR is the live testing ground — `R/ds.temp.test.R` is a throwaway
function (empty body, placeholder comments) used purely to exercise the
doc-suggestion pipeline. Its roxygen block intentionally has stale/incorrect
content (e.g. describes histogram-building behavior the function doesn't
actually have) to test whether Claude correctly flags staleness rather than
just filling gaps.

**Status: confirmed working end to end.** The `docs-suggest.yml` pipeline
authenticates correctly (WIF fully working, confirmed via Console auth
history), and — after several rounds of bugs (see `package-workflows`'s
`CLAUDE.md` for the full list) — now posts a single, clean, non-duplicated
suggestion comment. Verified across three consecutive fresh runs (commits
`test 13`, `test 14`, `test 15`), each checked directly via the GitHub API
(`original_commit_id` on the posted review comment) rather than relying on
the PR page's UI, which stacks every historical suggestion comment on the
same lines and easily reads as stale/contradictory at a glance:
- `test 13` confirmed `sanitize_field()` (bug #7) actually fixed the
  old-block+new-block duplication.
- `test 14` confirmed the switch to explicit `@title`/`@description` tags
  (bug #8).
- `test 15` confirmed removal of the leftover blank `#'` separator lines
  between sections (bug #9).

Do not treat this PR's commit history as representative of final quality —
it has intentionally been the crash-test dummy for every bug found so far.

## NOT YET DONE
- `docs-suggest-full.yml` (the monthly-sweep mode) has never been triggered.
- No real (non-test) function in this package has gone through the
  doc-suggestion pipeline yet.
- This PR (#4) should probably be closed without merging once testing is
  done — its commit history is entirely CI-testing noise (`ci: test`,
  `ci: test2`, etc.), not real work.
