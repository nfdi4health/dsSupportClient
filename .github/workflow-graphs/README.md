# Workflows

The GitHub Actions workflows of this repository, and how they connect.
The diagrams are generated from the workflow files by
[workflow-graphs](https://github.com/FlorianSchw/package-workflows) and
updated when the workflows change. Text outside the marked diagram
blocks is yours: add explanations anywhere, it is never overwritten.

## Overview

<!-- workflow-graphs:overview:start -->
| Name | File | Runs on | Calls | Produces |
|---|---|---|---|---|
| Update DESCRIPTION Authors | `check-author-included.yml` | PR into dev | FlorianSchw/package-workflows › authors-suggest.yml@main | Suggestion PR<br>Comment on the PR |
| Commit compatibility check | `commitlint.yml` | PR into dev | FlorianSchw/package-workflows › commitlint.yml@main | Check: commit messages follow Conventional Commits |
| Roxygen Doc Suggestions | `docs-suggest.yml` | PR into dev (only R/\*\*) · Monthly (day 1) · Manual run | FlorianSchw/package-workflows › roxygen-suggest.yml@main<br>FlorianSchw/package-workflows › workflow-keepalive.yml@main | Suggestion PR — *skipped for PRs from bot-suggest/ branches*<br>Comment on the PR — *skipped for PRs from bot-suggest/ branches*<br>Scheduled workflows kept enabled — *only on schedule* |
| R CMD Check | `R-CMD-Check.yml` | PR into dev (only R/\*\*, tests/\*\*, .github/\*\*, DESCRIPTION, NAMESPACE) · Weekly (Mon) · Manual run | FlorianSchw/package-workflows › r-cmd-check.yml@main<br>FlorianSchw/package-workflows › workflow-keepalive.yml@main | Check: R CMD check passes<br>Scheduled workflows kept enabled — *only on schedule* |
| Test setup suggestions | `test-suggest.yml` | PR into dev (only R/\*\*) · Monthly (day 1) · Manual run | FlorianSchw/package-workflows › test-suggest.yml@main<br>FlorianSchw/package-workflows › workflow-keepalive.yml@main | Suggestion PR — *skipped for PRs from bot-suggest/ branches*<br>Comment on the PR — *skipped for PRs from bot-suggest/ branches*<br>Issue for a likely bug in the code — *skipped for PRs from bot-suggest/ branches*<br>Scheduled workflows kept enabled — *only on schedule* |
| Workflow Graphs | `workflow-graph.yml` | PR into dev (only .github/workflows/\*\*) · Push to dev (only .github/workflows/\*\*) · Manual run | FlorianSchw/package-workflows › workflow-graphs.yml@main | Commit on the branch<br>Comment on the PR |
| Cleanup Suggestion Branch | `cleanup-suggestion-branch.yml` | PR closed | FlorianSchw/package-workflows › cleanup-suggestion-branch.yml@main | Bot branch deleted — *only for PRs from bot-suggest/ branches* |
| Release | `release-trigger.yml` | PR into main | FlorianSchw/package-workflows › r-cmd-check.yml@main<br>FlorianSchw/package-workflows › merge-pull-request.yml@main<br>FlorianSchw/package-workflows › create-issue.yml@main<br>FlorianSchw/package-workflows › trigger-release-publish.yml@main | Check: R CMD check passes — *only if the PR comes from dev*<br>PR merged — *if check succeeds*<br>Issue for the PR author — *if check fails*<br>starts **Publish Release** |
| Publish Release | `release-publish.yml` | Dispatch: release-publish | FlorianSchw/package-workflows › package-release.yml@main | Version commit, tag and draft release |
| Require Head Branch | `require-head-branch.yml` | PR into main | FlorianSchw/package-workflows › require-head-branch.yml@main | Check: PR comes from dev |

### PR into dev

```mermaid
flowchart LR
  ev(["PR into dev"])
  wf_check_author_included_yml["Update DESCRIPTION Authors"]
  ev --> wf_check_author_included_yml
  wf_commitlint_yml["Commit compatibility check"]
  ev --> wf_commitlint_yml
  wf_docs_suggest_yml["Roxygen Doc Suggestions<br/>only R/#42;#42;"]
  ev --> wf_docs_suggest_yml
  wf_R_CMD_Check_yml["R CMD Check<br/>only R/#42;#42;, tests/#42;#42;,<br/>.github/#42;#42;, DESCRIPTION,<br/>NAMESPACE"]
  ev --> wf_R_CMD_Check_yml
  wf_test_suggest_yml["Test setup suggestions<br/>only R/#42;#42;"]
  ev --> wf_test_suggest_yml
  wf_workflow_graph_yml["Workflow Graphs<br/>only .github/workflows/#42;#42;"]
  ev --> wf_workflow_graph_yml
  out_1(["Suggestion PR"]):::outcome
  out_2(["Comment on the PR"]):::outcome
  out_3(["Check: commit messages<br/>follow Conventional<br/>Commits"]):::outcome
  out_4(["Scheduled workflows kept<br/>enabled"]):::outcome
  out_5(["Check: R CMD check passes"]):::outcome
  out_6(["Issue for a likely bug in<br/>the code"]):::outcome
  out_7(["Commit on the branch"]):::outcome
  wf_check_author_included_yml --> out_1
  wf_check_author_included_yml --> out_2
  wf_commitlint_yml --> out_3
  wf_docs_suggest_yml -- "skipped for PRs from<br/>bot-suggest/ branches" --> out_1
  wf_docs_suggest_yml -- "skipped for PRs from<br/>bot-suggest/ branches" --> out_2
  wf_docs_suggest_yml -- "only on schedule" --> out_4
  wf_R_CMD_Check_yml --> out_5
  wf_R_CMD_Check_yml -- "only on schedule" --> out_4
  wf_test_suggest_yml -- "skipped for PRs from<br/>bot-suggest/ branches" --> out_1
  wf_test_suggest_yml -- "skipped for PRs from<br/>bot-suggest/ branches" --> out_2
  wf_test_suggest_yml -- "skipped for PRs from<br/>bot-suggest/ branches" --> out_6
  wf_test_suggest_yml -- "only on schedule" --> out_4
  wf_workflow_graph_yml --> out_7
  wf_workflow_graph_yml --> out_2
  classDef outcome stroke-dasharray: 4 3
```

### PR closed

```mermaid
flowchart LR
  ev(["PR closed"])
  wf_cleanup_suggestion_branch_yml["Cleanup Suggestion Branch"]
  ev --> wf_cleanup_suggestion_branch_yml
  out_1(["Bot branch deleted"]):::outcome
  wf_cleanup_suggestion_branch_yml -- "only for PRs from<br/>bot-suggest/ branches" --> out_1
  classDef outcome stroke-dasharray: 4 3
```

### PR into main

```mermaid
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
  wf_release_trigger_yml -- "only if the PR comes from<br/>dev" --> out_1
  wf_release_trigger_yml -- "if check succeeds" --> out_2
  wf_release_trigger_yml -- "if check fails" --> out_3
  wf_require_head_branch_yml --> out_4
  wf_release_publish_yml --> out_5
  classDef outcome stroke-dasharray: 4 3
```

### Push to dev

```mermaid
flowchart LR
  ev(["Push to dev"])
  wf_workflow_graph_yml["Workflow Graphs<br/>only .github/workflows/#42;#42;"]
  ev --> wf_workflow_graph_yml
  out_1(["Commit on the branch"]):::outcome
  out_2(["Comment on the PR"]):::outcome
  wf_workflow_graph_yml --> out_1
  wf_workflow_graph_yml --> out_2
  classDef outcome stroke-dasharray: 4 3
```

### On a schedule

```mermaid
flowchart LR
  ev(["On a schedule"])
  wf_docs_suggest_yml["Roxygen Doc Suggestions<br/>monthly (day 1)"]
  ev --> wf_docs_suggest_yml
  wf_R_CMD_Check_yml["R CMD Check<br/>weekly (Mon)"]
  ev --> wf_R_CMD_Check_yml
  wf_test_suggest_yml["Test setup suggestions<br/>monthly (day 1)"]
  ev --> wf_test_suggest_yml
  out_1(["Suggestion PR"]):::outcome
  out_2(["Comment on the PR"]):::outcome
  out_3(["Scheduled workflows kept<br/>enabled"]):::outcome
  out_4(["Check: R CMD check passes"]):::outcome
  out_5(["Issue for a likely bug in<br/>the code"]):::outcome
  wf_docs_suggest_yml -- "skipped for PRs from<br/>bot-suggest/ branches" --> out_1
  wf_docs_suggest_yml -- "skipped for PRs from<br/>bot-suggest/ branches" --> out_2
  wf_docs_suggest_yml -- "only on schedule" --> out_3
  wf_R_CMD_Check_yml --> out_4
  wf_R_CMD_Check_yml -- "only on schedule" --> out_3
  wf_test_suggest_yml -- "skipped for PRs from<br/>bot-suggest/ branches" --> out_1
  wf_test_suggest_yml -- "skipped for PRs from<br/>bot-suggest/ branches" --> out_2
  wf_test_suggest_yml -- "skipped for PRs from<br/>bot-suggest/ branches" --> out_5
  wf_test_suggest_yml -- "only on schedule" --> out_3
  classDef outcome stroke-dasharray: 4 3
```
<!-- workflow-graphs:overview:end -->

## Workflows

<!-- workflow-graphs:detail:check-author-included.yml:start -->
### Update DESCRIPTION Authors

<sub>`check-author-included.yml`</sub>

```mermaid
flowchart TD
  start(["PR into dev"])
  subgraph job_check_authors ["check-authors"]
    direction TB
    job_check_authors__suggest_authors["• Checkout shared scripts<br/>• Find and add missing<br/>contributors<br/>• Resolve push token<br/>• Commit DESCRIPTION<br/>update"]
  end
  start --> job_check_authors
  classDef condnote stroke-dasharray: 4 3
```
<!-- workflow-graphs:detail:check-author-included.yml:end -->

<!-- workflow-graphs:detail:commitlint.yml:start -->
### Commit compatibility check

<sub>`commitlint.yml`</sub>

```mermaid
flowchart TD
  start(["PR into dev"])
  subgraph job_commitlint ["commitlint"]
    direction TB
    job_commitlint__lint["• Checkout shared<br/>commitlint config<br/>• commitlint-github-action"]
  end
  start --> job_commitlint
  classDef condnote stroke-dasharray: 4 3
```
<!-- workflow-graphs:detail:commitlint.yml:end -->

<!-- workflow-graphs:detail:docs-suggest.yml:start -->
### Roxygen Doc Suggestions

<sub>`docs-suggest.yml`</sub>

```mermaid
flowchart TD
  start(["PR into dev<br/>Monthly (day 1)<br/>Manual run"])
  subgraph job_suggest_docs ["suggest-docs"]
    direction TB
    job_suggest_docs__suggest_docs["skipped for PRs from<br/>bot-suggest/ branches<br/>• Checkout shared scripts<br/>• Determine files to check<br/>• Get Anthropic access<br/>token<br/>• Run roxygen suggestion<br/>script<br/>• Resolve push token<br/>• Commit roxygen<br/>suggestions"]
  end
  start --> job_suggest_docs
  subgraph job_keepalive ["keepalive"]
    direction TB
    job_keepalive__cond["only on schedule"]:::condnote
    job_keepalive__keepalive["• gh-workflow-keepalive"]
    job_keepalive__cond ~~~ job_keepalive__keepalive
  end
  start --> job_keepalive
  classDef condnote stroke-dasharray: 4 3
```
<!-- workflow-graphs:detail:docs-suggest.yml:end -->

<!-- workflow-graphs:detail:R-CMD-Check.yml:start -->
### R CMD Check

<sub>`R-CMD-Check.yml`</sub>

```mermaid
flowchart TD
  start(["PR into dev<br/>Weekly (Mon)<br/>Manual run"])
  subgraph job_check ["check"]
    direction TB
    job_check__R_CMD_check["• Install extra apt<br/>packages<br/>• Format extra R package<br/>list<br/>• check-r-package<br/>• Show testthat output<br/>• Test coverage"]
  end
  start --> job_check
  subgraph job_keepalive ["keepalive"]
    direction TB
    job_keepalive__cond["only on schedule"]:::condnote
    job_keepalive__keepalive["• gh-workflow-keepalive"]
    job_keepalive__cond ~~~ job_keepalive__keepalive
  end
  start --> job_keepalive
  classDef condnote stroke-dasharray: 4 3
```
<!-- workflow-graphs:detail:R-CMD-Check.yml:end -->

<!-- workflow-graphs:detail:test-suggest.yml:start -->
### Test setup suggestions

<sub>`test-suggest.yml`</sub>

```mermaid
flowchart TD
  start(["PR into dev<br/>Monthly (day 1)<br/>Manual run"])
  subgraph job_suggest_docs ["suggest-docs"]
    direction TB
    job_suggest_docs__suggest_tests["skipped for PRs from<br/>bot-suggest/ branches<br/>• Checkout shared scripts<br/>• Determine files to check<br/>• Get Anthropic access<br/>token<br/>• Run test suggestion<br/>script<br/>• Resolve push token<br/>• Commit generated tests"]
  end
  start --> job_suggest_docs
  subgraph job_keepalive ["keepalive"]
    direction TB
    job_keepalive__cond["only on schedule"]:::condnote
    job_keepalive__keepalive["• gh-workflow-keepalive"]
    job_keepalive__cond ~~~ job_keepalive__keepalive
  end
  start --> job_keepalive
  classDef condnote stroke-dasharray: 4 3
```
<!-- workflow-graphs:detail:test-suggest.yml:end -->

<!-- workflow-graphs:detail:workflow-graph.yml:start -->
### Workflow Graphs

<sub>`workflow-graph.yml`</sub>

```mermaid
flowchart TD
  start(["Push to dev<br/>PR into dev<br/>Manual run"])
  subgraph job_workflow_graphs ["workflow-graphs"]
    direction TB
    job_workflow_graphs__workflow_graphs["• Checkout shared scripts<br/>• Draw workflow diagrams<br/>• Resolve push token<br/>• Commit the README"]
  end
  start --> job_workflow_graphs
  classDef condnote stroke-dasharray: 4 3
```
<!-- workflow-graphs:detail:workflow-graph.yml:end -->
<!-- workflow-graphs:detail:cleanup-suggestion-branch.yml:start -->
### Cleanup Suggestion Branch

<sub>`cleanup-suggestion-branch.yml`</sub>

```mermaid
flowchart TD
  start(["PR closed"])
  subgraph job_cleanup ["cleanup"]
    direction TB
    job_cleanup__cleanup["only for PRs from<br/>bot-suggest/ branches<br/>• Delete the suggestion<br/>branch"]
  end
  start --> job_cleanup
  classDef condnote stroke-dasharray: 4 3
```
<!-- workflow-graphs:detail:cleanup-suggestion-branch.yml:end -->

<!-- workflow-graphs:detail:release-trigger.yml:start -->
### Release

<sub>`release-trigger.yml`</sub>

```mermaid
flowchart TD
  start(["PR into main"])
  subgraph job_check ["check"]
    direction TB
    job_check__cond["only if the PR comes from<br/>dev"]:::condnote
    job_check__R_CMD_check["• Install extra apt<br/>packages<br/>• Format extra R package<br/>list<br/>• check-r-package<br/>• Show testthat output<br/>• Test coverage"]
    job_check__cond ~~~ job_check__R_CMD_check
  end
  start --> job_check
  subgraph job_on_success ["on-success"]
    direction TB
    job_on_success__merge["• Merge PR"]
  end
  job_check -- "success" --> job_on_success
  subgraph job_on_failure ["on-failure"]
    direction TB
    job_on_failure__create_issue["• Build assignee list<br/>• create-an-issue"]
  end
  job_check -- "failure" --> job_on_failure
  subgraph job_trigger_release ["trigger-release"]
    direction TB
    job_trigger_release__dispatch["• Dispatch release-publish"]
  end
  job_on_success -- "success" --> job_trigger_release
  wf_release_publish_yml(["Publish Release"])
  job_trigger_release -. "dispatch: release-publish" .-> wf_release_publish_yml
  classDef condnote stroke-dasharray: 4 3
```
<!-- workflow-graphs:detail:release-trigger.yml:end -->

<!-- workflow-graphs:detail:release-publish.yml:start -->
### Publish Release

<sub>`release-publish.yml`</sub>

```mermaid
flowchart TD
  start(["Dispatch: release-publish"])
  subgraph job_release ["release"]
    direction TB
    job_release__release["• Checkout<br/>• Checkout shared release<br/>config<br/>• Install semantic-release<br/>and plugins<br/>• Verify npm registry<br/>signatures<br/>• Resolve push token<br/>• Release"]
  end
  start --> job_release
  classDef condnote stroke-dasharray: 4 3
```
<!-- workflow-graphs:detail:release-publish.yml:end -->

<!-- workflow-graphs:detail:require-head-branch.yml:start -->
### Require Head Branch

<sub>`require-head-branch.yml`</sub>

```mermaid
flowchart TD
  start(["PR into main"])
  subgraph job_require_head_branch ["require-head-branch"]
    direction TB
    job_require_head_branch__verify_source_branch["• Verify PR source branch"]
  end
  start --> job_require_head_branch
  classDef condnote stroke-dasharray: 4 3
```
<!-- workflow-graphs:detail:require-head-branch.yml:end -->

