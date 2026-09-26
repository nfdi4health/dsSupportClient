# Workflows

The GitHub Actions workflows of this repository, and how they connect.
The diagrams are generated from the workflow files by
[workflow-graphs](https://github.com/FlorianSchw/package-workflows) and
updated when the workflows change. Text outside the marked diagram
blocks is yours: add explanations anywhere, it is never overwritten.

## Overview

<!-- workflow-graphs:overview:start -->
### All workflows

| Name | File | Runs on | Calls | Produces |
|---|---|---|---|---|
| Update DESCRIPTION Authors | `check-author-included.yml` | PR into dev | FlorianSchw/package-workflows › authors-suggest.yml@main | • Suggestion PR<br>• Comment on the PR — *only on pull request* |
| Commit compatibility check | `commitlint.yml` | PR into dev | FlorianSchw/package-workflows › commitlint.yml@main | Check: commit messages follow Conventional Commits |
| Roxygen Doc Suggestions | `docs-suggest.yml` | • PR into dev (only R/\*\*)<br>• Monthly (day 1)<br>• Manual run | • FlorianSchw/package-workflows › roxygen-suggest.yml@main<br>• FlorianSchw/package-workflows › workflow-keepalive.yml@main | • Suggestion PR — *skipped for PRs from bot-suggest/ branches*<br>• Comment on the PR — *only on pull request, skipped for PRs from bot-suggest/ branches*<br>• Scheduled workflows kept enabled — *only on schedule* |
| R CMD Check | `R-CMD-Check.yml` | • PR into dev (only R/\*\*, tests/\*\*, .github/\*\*, DESCRIPTION, NAMESPACE)<br>• Weekly (Mon)<br>• Manual run | • FlorianSchw/package-workflows › r-cmd-check.yml@main<br>• FlorianSchw/package-workflows › workflow-keepalive.yml@main | • Check: R CMD check passes<br>• Scheduled workflows kept enabled — *only on schedule* |
| Test setup suggestions | `test-suggest.yml` | • PR into dev (only R/\*\*)<br>• Monthly (day 1)<br>• Manual run | • FlorianSchw/package-workflows › test-suggest.yml@main<br>• FlorianSchw/package-workflows › workflow-keepalive.yml@main | • Suggestion PR — *skipped for PRs from bot-suggest/ branches*<br>• Comment on the PR — *only on pull request, skipped for PRs from bot-suggest/ branches*<br>• Issue for a likely bug in the code — *skipped for PRs from bot-suggest/ branches*<br>• Scheduled workflows kept enabled — *only on schedule* |
| Workflow Graphs | `workflow-graph.yml` | • PR into dev (only .github/workflows/\*\*)<br>• Push to dev (only .github/workflows/\*\*)<br>• Manual run | FlorianSchw/package-workflows › workflow-graphs.yml@main | • Commit on the branch — *only on push*<br>• Note on the PR: runs on push only — *only on pull request* |
| Cleanup Suggestion Branch | `cleanup-suggestion-branch.yml` | PR closed | FlorianSchw/package-workflows › cleanup-suggestion-branch.yml@main | Bot branch deleted — *only for PRs from bot-suggest/ branches* |
| Release | `release-trigger.yml` | PR into main | • FlorianSchw/package-workflows › r-cmd-check.yml@main<br>• FlorianSchw/package-workflows › merge-pull-request.yml@main<br>• FlorianSchw/package-workflows › create-issue.yml@main<br>• FlorianSchw/package-workflows › trigger-release-publish.yml@main | • Check: R CMD check passes — *only if the PR comes from dev*<br>• PR merged — *if check succeeds*<br>• Issue for the PR author — *if check fails*<br>• starts **Publish Release** |
| Publish Release | `release-publish.yml` | Dispatch: release-publish | FlorianSchw/package-workflows › package-release.yml@main | Version commit, tag and draft release |
| Require Head Branch | `require-head-branch.yml` | PR into main | FlorianSchw/package-workflows › require-head-branch.yml@main | Check: PR comes from dev |

### What runs when

What each event starts: the workflows, the workflows those start in turn (dotted arrows), and what comes out of it — with the condition on the arrow where there is one.

#### When a pull request into dev is opened or updated

```mermaid
%%{init: {"flowchart": {"rankSpacing": 140, "nodeSpacing": 45}}}%%
flowchart LR
  ev(["PR into dev"])
  wf_check_author_included_yml["Update DESCRIPTION Authors"]
  ev --> wf_check_author_included_yml
  wf_commitlint_yml["Commit compatibility check"]
  ev --> wf_commitlint_yml
  wf_docs_suggest_yml["Roxygen Doc Suggestions<br/>only R/#42;#42;<br/>skipped for PRs from<br/>bot-suggest/ branches"]
  ev --> wf_docs_suggest_yml
  wf_R_CMD_Check_yml["R CMD Check<br/>only R/#42;#42;, tests/#42;#42;,<br/>.github/#42;#42;, DESCRIPTION,<br/>NAMESPACE"]
  ev --> wf_R_CMD_Check_yml
  wf_test_suggest_yml["Test setup suggestions<br/>only R/#42;#42;<br/>skipped for PRs from<br/>bot-suggest/ branches"]
  ev --> wf_test_suggest_yml
  wf_workflow_graph_yml["Workflow Graphs<br/>only .github/workflows/#42;#42;"]
  ev --> wf_workflow_graph_yml
  out_1(["Suggestion PR"]):::outcome
  out_2(["Comment on the PR"]):::outcome
  out_3(["Check: commit messages<br/>follow Conventional<br/>Commits"]):::outcome
  out_4(["Check: R CMD check passes"]):::outcome
  out_5(["Issue for a likely bug in<br/>the code"]):::outcome
  out_6(["Note on the PR: runs on<br/>push only"]):::outcome
  wf_check_author_included_yml --> out_1
  wf_check_author_included_yml --> out_2
  wf_commitlint_yml --> out_3
  wf_docs_suggest_yml --> out_1
  wf_docs_suggest_yml --> out_2
  wf_R_CMD_Check_yml --> out_4
  wf_test_suggest_yml --> out_1
  wf_test_suggest_yml --> out_2
  wf_test_suggest_yml --> out_5
  wf_workflow_graph_yml --> out_6
  classDef outcome stroke-dasharray: 4 3
```

#### When a pull request is closed

```mermaid
%%{init: {"flowchart": {"rankSpacing": 140, "nodeSpacing": 45}}}%%
flowchart LR
  ev(["PR closed"])
  wf_cleanup_suggestion_branch_yml["Cleanup Suggestion Branch<br/>only for PRs from<br/>bot-suggest/ branches"]
  ev --> wf_cleanup_suggestion_branch_yml
  out_1(["Bot branch deleted"]):::outcome
  wf_cleanup_suggestion_branch_yml --> out_1
  classDef outcome stroke-dasharray: 4 3
```

#### When a pull request into main is opened or updated

```mermaid
%%{init: {"flowchart": {"rankSpacing": 140, "nodeSpacing": 45}}}%%
flowchart LR
  ev(["PR into main"])
  wf_release_trigger_yml["Release"]
  ev --> wf_release_trigger_yml
  wf_require_head_branch_yml["Require Head Branch"]
  ev --> wf_require_head_branch_yml
  wf_release_publish_yml["Publish Release"]
  wf_release_trigger_yml -. "dispatch: release-publish" .-> wf_release_publish_yml
  out_1(["Check: R CMD check passes"]):::outcome
  out_2(["PR merged"]):::outcome
  out_3(["Issue for the PR author"]):::outcome
  out_4(["Check: PR comes from dev"]):::outcome
  out_5(["Version commit, tag and<br/>draft release"]):::outcome
  wf_release_trigger_yml -- "only if the PR comes<br/>from dev" --> out_1
  wf_release_trigger_yml -- "if check succeeds" --> out_2
  wf_release_trigger_yml -- "if check fails" --> out_3
  wf_require_head_branch_yml --> out_4
  wf_release_publish_yml --> out_5
  classDef outcome stroke-dasharray: 4 3
```

#### On a push to dev

```mermaid
%%{init: {"flowchart": {"rankSpacing": 140, "nodeSpacing": 45}}}%%
flowchart LR
  ev(["Push to dev"])
  wf_workflow_graph_yml["Workflow Graphs<br/>only .github/workflows/#42;#42;"]
  ev --> wf_workflow_graph_yml
  out_1(["Commit on the branch"]):::outcome
  wf_workflow_graph_yml --> out_1
  classDef outcome stroke-dasharray: 4 3
```

#### On a schedule

```mermaid
%%{init: {"flowchart": {"rankSpacing": 140, "nodeSpacing": 45}}}%%
flowchart LR
  ev(["On a schedule"])
  wf_docs_suggest_yml["Roxygen Doc Suggestions<br/>monthly (day 1)"]
  ev --> wf_docs_suggest_yml
  wf_R_CMD_Check_yml["R CMD Check<br/>weekly (Mon)"]
  ev --> wf_R_CMD_Check_yml
  wf_test_suggest_yml["Test setup suggestions<br/>monthly (day 1)"]
  ev --> wf_test_suggest_yml
  out_1(["Suggestion PR"]):::outcome
  out_2(["Scheduled workflows kept<br/>enabled"]):::outcome
  out_3(["Check: R CMD check passes"]):::outcome
  out_4(["Issue for a likely bug in<br/>the code"]):::outcome
  wf_docs_suggest_yml -- "skipped for PRs from<br/>bot-suggest/<br/>branches" --> out_1
  wf_docs_suggest_yml --> out_2
  wf_R_CMD_Check_yml --> out_3
  wf_R_CMD_Check_yml --> out_2
  wf_test_suggest_yml -- "skipped for PRs from<br/>bot-suggest/<br/>branches" --> out_1
  wf_test_suggest_yml -- "skipped for PRs from<br/>bot-suggest/<br/>branches" --> out_4
  wf_test_suggest_yml --> out_2
  classDef outcome stroke-dasharray: 4 3
```
<!-- workflow-graphs:overview:end -->

## Workflows

