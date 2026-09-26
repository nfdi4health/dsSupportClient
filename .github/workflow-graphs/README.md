# Workflows

The GitHub Actions workflows of this repository, and how they connect.
The diagrams are generated from the workflow files by
[workflow-graphs](https://github.com/FlorianSchw/package-workflows) and
updated when the workflows change. Text outside the marked diagram
blocks is yours: add explanations anywhere, it is never overwritten.

## Overview

<!-- workflow-graphs:overview:start -->
| Workflow | Runs on | Calls | Produces |
|---|---|---|---|
| **Update DESCRIPTION Authors**<br>`check-author-included.yml` | PR into dev | FlorianSchw/package-workflows › authors-suggest.yml@main | Suggestion PR<br>Comment on the PR |
| **Cleanup Suggestion Branch**<br>`cleanup-suggestion-branch.yml` | PR closed | FlorianSchw/package-workflows › cleanup-suggestion-branch.yml@main | Bot branch deleted |
| **Commit compatibility check**<br>`commitlint.yml` | PR into dev | FlorianSchw/package-workflows › commitlint.yml@main | Check result on the PR |
| **Roxygen Doc Suggestions**<br>`docs-suggest.yml` | PR into dev (only R/\*\*) · Monthly (day 1) · Manual run | FlorianSchw/package-workflows › roxygen-suggest.yml@main<br>FlorianSchw/package-workflows › workflow-keepalive.yml@main | Suggestion PR<br>Comment on the PR<br>Scheduled workflows kept enabled |
| **R CMD Check**<br>`R-CMD-Check.yml` | PR into dev (only R/\*\*, tests/\*\* (+3)) · Weekly (Mon) · Manual run | FlorianSchw/package-workflows › r-cmd-check.yml@main<br>FlorianSchw/package-workflows › workflow-keepalive.yml@main | Check result on the PR<br>Scheduled workflows kept enabled |
| **Publish Release**<br>`release-publish.yml` | Dispatch: release-publish | FlorianSchw/package-workflows › package-release.yml@main | Version commit, tag and draft release |
| **Release**<br>`release-trigger.yml` | PR into main | FlorianSchw/package-workflows › r-cmd-check.yml@main<br>FlorianSchw/package-workflows › merge-pull-request.yml@main<br>FlorianSchw/package-workflows › create-issue.yml@main<br>FlorianSchw/package-workflows › trigger-release-publish.yml@main | Check result on the PR<br>PR merged<br>Issue<br>starts **Publish Release** |
| **Require Head Branch**<br>`require-head-branch.yml` | PR into main | FlorianSchw/package-workflows › require-head-branch.yml@main | Check result on the PR |
| **Test setup suggestions**<br>`test-suggest.yml` | PR into dev (only R/\*\*) · Monthly (day 1) · Manual run | FlorianSchw/package-workflows › test-suggest.yml@main<br>FlorianSchw/package-workflows › workflow-keepalive.yml@main | Suggestion PR<br>Comment on the PR<br>Issue<br>Scheduled workflows kept enabled |
| **Workflow Graphs**<br>`workflow-graph.yml` | PR into dev (only .github/workflows/\*\*) · Push to dev (only .github/workflows/\*\*) · Manual run | FlorianSchw/package-workflows › workflow-graphs.yml@main | Commit on the branch<br>Comment on the PR |

### PR into dev

```mermaid
flowchart LR
  ev(["PR into dev"])
  wf_check_author_included_yml["Update DESCRIPTION Authors<br/>check-author-included.yml"]
  ev --> wf_check_author_included_yml
  wf_commitlint_yml["Commit compatibility check<br/>commitlint.yml"]
  ev --> wf_commitlint_yml
  wf_docs_suggest_yml["Roxygen Doc Suggestions<br/>docs-suggest.yml<br/>only R/#42;#42;"]
  ev --> wf_docs_suggest_yml
  wf_R_CMD_Check_yml["R CMD Check<br/>R-CMD-Check.yml<br/>only R/#42;#42;, tests/#42;#42; (+3)"]
  ev --> wf_R_CMD_Check_yml
  wf_test_suggest_yml["Test setup suggestions<br/>test-suggest.yml<br/>only R/#42;#42;"]
  ev --> wf_test_suggest_yml
  wf_workflow_graph_yml["Workflow Graphs<br/>workflow-graph.yml<br/>only .github/workflows/#42;#42;"]
  ev --> wf_workflow_graph_yml
  out_1(["Suggestion PR"]):::outcome
  out_2(["Comment on the PR"]):::outcome
  out_3(["Check result on the PR"]):::outcome
  out_4(["Scheduled workflows kept<br/>enabled"]):::outcome
  out_5(["Issue"]):::outcome
  out_6(["Commit on the branch"]):::outcome
  wf_check_author_included_yml --> out_1
  wf_check_author_included_yml --> out_2
  wf_commitlint_yml --> out_3
  wf_docs_suggest_yml --> out_1
  wf_docs_suggest_yml --> out_2
  wf_docs_suggest_yml --> out_4
  wf_R_CMD_Check_yml --> out_3
  wf_R_CMD_Check_yml --> out_4
  wf_test_suggest_yml --> out_1
  wf_test_suggest_yml --> out_2
  wf_test_suggest_yml --> out_5
  wf_test_suggest_yml --> out_4
  wf_workflow_graph_yml --> out_6
  wf_workflow_graph_yml --> out_2
  classDef outcome stroke-dasharray: 4 3
```

### PR closed

```mermaid
flowchart LR
  ev(["PR closed"])
  wf_cleanup_suggestion_branch_yml["Cleanup Suggestion Branch<br/>cleanup-suggestion-<br/>branch.yml"]
  ev --> wf_cleanup_suggestion_branch_yml
  out_1(["Bot branch deleted"]):::outcome
  wf_cleanup_suggestion_branch_yml --> out_1
  classDef outcome stroke-dasharray: 4 3
```

### PR into main

```mermaid
flowchart LR
  ev(["PR into main"])
  wf_release_trigger_yml["Release<br/>release-trigger.yml"]
  ev --> wf_release_trigger_yml
  wf_require_head_branch_yml["Require Head Branch<br/>require-head-branch.yml"]
  ev --> wf_require_head_branch_yml
  wf_release_publish_yml["Publish Release<br/>release-publish.yml"]
  wf_release_trigger_yml -. "dispatch: release-publish" .-> wf_release_publish_yml
  out_1(["Check result on the PR"]):::outcome
  out_2(["PR merged"]):::outcome
  out_3(["Issue"]):::outcome
  out_4(["Version commit, tag and<br/>draft release"]):::outcome
  wf_release_trigger_yml --> out_1
  wf_release_trigger_yml --> out_2
  wf_release_trigger_yml --> out_3
  wf_require_head_branch_yml --> out_1
  wf_release_publish_yml --> out_4
  classDef outcome stroke-dasharray: 4 3
```

### Push to dev

```mermaid
flowchart LR
  ev(["Push to dev"])
  wf_workflow_graph_yml["Workflow Graphs<br/>workflow-graph.yml<br/>only .github/workflows/#42;#42;"]
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
  wf_docs_suggest_yml["Roxygen Doc Suggestions<br/>docs-suggest.yml<br/>monthly (day 1)"]
  ev --> wf_docs_suggest_yml
  wf_R_CMD_Check_yml["R CMD Check<br/>R-CMD-Check.yml<br/>weekly (Mon)"]
  ev --> wf_R_CMD_Check_yml
  wf_test_suggest_yml["Test setup suggestions<br/>test-suggest.yml<br/>monthly (day 1)"]
  ev --> wf_test_suggest_yml
  out_1(["Suggestion PR"]):::outcome
  out_2(["Comment on the PR"]):::outcome
  out_3(["Scheduled workflows kept<br/>enabled"]):::outcome
  out_4(["Check result on the PR"]):::outcome
  out_5(["Issue"]):::outcome
  wf_docs_suggest_yml --> out_1
  wf_docs_suggest_yml --> out_2
  wf_docs_suggest_yml --> out_3
  wf_R_CMD_Check_yml --> out_4
  wf_R_CMD_Check_yml --> out_3
  wf_test_suggest_yml --> out_1
  wf_test_suggest_yml --> out_2
  wf_test_suggest_yml --> out_5
  wf_test_suggest_yml --> out_3
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
    job_check_authors__ref["calls<br/>FlorianSchw/<br/>package-workflows<br/>authors-suggest.yml@main"]:::refnote
    job_check_authors__suggest_authors["suggest-authors<br/>• Checkout shared scripts<br/>• Find and add missing<br/>contributors<br/>• Resolve push token<br/>• Commit DESCRIPTION<br/>update"]
    job_check_authors__ref ~~~ job_check_authors__suggest_authors
  end
  start --> job_check_authors
  classDef refnote stroke-dasharray: 4 3
```
<!-- workflow-graphs:detail:check-author-included.yml:end -->

<!-- workflow-graphs:detail:cleanup-suggestion-branch.yml:start -->
### Cleanup Suggestion Branch

<sub>`cleanup-suggestion-branch.yml`</sub>

```mermaid
flowchart TD
  start(["PR closed"])
  subgraph job_cleanup ["cleanup"]
    direction TB
    job_cleanup__ref["calls<br/>FlorianSchw/<br/>package-workflows<br/>cleanup-suggestion-<br/>branch.yml@main"]:::refnote
    job_cleanup__cleanup["cleanup<br/>if:<br/>startsWith(github.event.pull_request.head.ref,<br/>'bot-sugge...<br/>• Delete the suggestion<br/>branch"]
    job_cleanup__ref ~~~ job_cleanup__cleanup
  end
  start --> job_cleanup
  classDef refnote stroke-dasharray: 4 3
```
<!-- workflow-graphs:detail:cleanup-suggestion-branch.yml:end -->

<!-- workflow-graphs:detail:commitlint.yml:start -->
### Commit compatibility check

<sub>`commitlint.yml`</sub>

```mermaid
flowchart TD
  start(["PR into dev"])
  subgraph job_commitlint ["commitlint"]
    direction TB
    job_commitlint__ref["calls<br/>FlorianSchw/<br/>package-workflows<br/>commitlint.yml@main"]:::refnote
    job_commitlint__lint["lint<br/>• Checkout shared<br/>commitlint config<br/>• commitlint-github-action"]
    job_commitlint__ref ~~~ job_commitlint__lint
  end
  start --> job_commitlint
  classDef refnote stroke-dasharray: 4 3
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
    job_suggest_docs__ref["calls<br/>FlorianSchw/<br/>package-workflows<br/>roxygen-suggest.yml@main"]:::refnote
    job_suggest_docs__suggest_docs["suggest-docs<br/>not for bot-suggest/<br/>branches<br/>• Checkout shared scripts<br/>• Determine files to check<br/>• Get Anthropic access<br/>token<br/>• Run roxygen suggestion<br/>script<br/>• Resolve push token<br/>• Commit roxygen<br/>suggestions"]
    job_suggest_docs__ref ~~~ job_suggest_docs__suggest_docs
  end
  start --> job_suggest_docs
  subgraph job_keepalive ["keepalive"]
    direction TB
    job_keepalive__ref["calls<br/>FlorianSchw/<br/>package-workflows<br/>workflow-<br/>keepalive.yml@main<br/>only on schedule"]:::refnote
    job_keepalive__keepalive["keepalive<br/>• gh-workflow-keepalive"]
    job_keepalive__ref ~~~ job_keepalive__keepalive
  end
  start --> job_keepalive
  classDef refnote stroke-dasharray: 4 3
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
    job_check__ref["calls<br/>FlorianSchw/<br/>package-workflows<br/>r-cmd-check.yml@main"]:::refnote
    job_check__R_CMD_check["R-CMD-check<br/>• Install extra apt<br/>packages<br/>• Format extra R package<br/>list<br/>• check-r-package<br/>• Show testthat output<br/>• Test coverage"]
    job_check__ref ~~~ job_check__R_CMD_check
  end
  start --> job_check
  subgraph job_keepalive ["keepalive"]
    direction TB
    job_keepalive__ref["calls<br/>FlorianSchw/<br/>package-workflows<br/>workflow-<br/>keepalive.yml@main<br/>only on schedule"]:::refnote
    job_keepalive__keepalive["keepalive<br/>• gh-workflow-keepalive"]
    job_keepalive__ref ~~~ job_keepalive__keepalive
  end
  start --> job_keepalive
  classDef refnote stroke-dasharray: 4 3
```
<!-- workflow-graphs:detail:R-CMD-Check.yml:end -->

<!-- workflow-graphs:detail:release-publish.yml:start -->
### Publish Release

<sub>`release-publish.yml`</sub>

```mermaid
flowchart TD
  start(["Dispatch: release-publish"])
  subgraph job_release ["release"]
    direction TB
    job_release__ref["calls<br/>FlorianSchw/<br/>package-workflows<br/>package-release.yml@main"]:::refnote
    job_release__release["Release<br/>• Checkout<br/>• Checkout shared release<br/>config<br/>• Install semantic-release<br/>and plugins<br/>• Verify npm registry<br/>signatures<br/>• Resolve push token<br/>• Release"]
    job_release__ref ~~~ job_release__release
  end
  start --> job_release
  classDef refnote stroke-dasharray: 4 3
```
<!-- workflow-graphs:detail:release-publish.yml:end -->

<!-- workflow-graphs:detail:release-trigger.yml:start -->
### Release

<sub>`release-trigger.yml`</sub>

```mermaid
flowchart TD
  start(["PR into main"])
  subgraph job_check ["check"]
    direction TB
    job_check__ref["calls<br/>FlorianSchw/<br/>package-workflows<br/>r-cmd-check.yml@main<br/>only if the PR comes from<br/>dev"]:::refnote
    job_check__R_CMD_check["R-CMD-check<br/>• Install extra apt<br/>packages<br/>• Format extra R package<br/>list<br/>• check-r-package<br/>• Show testthat output<br/>• Test coverage"]
    job_check__ref ~~~ job_check__R_CMD_check
  end
  start --> job_check
  subgraph job_on_success ["on-success"]
    direction TB
    job_on_success__ref["calls<br/>FlorianSchw/<br/>package-workflows<br/>merge-pull-<br/>request.yml@main"]:::refnote
    job_on_success__merge["merge<br/>• Merge PR"]
    job_on_success__ref ~~~ job_on_success__merge
  end
  job_check -- "success" --> job_on_success
  subgraph job_on_failure ["on-failure"]
    direction TB
    job_on_failure__ref["calls<br/>FlorianSchw/<br/>package-workflows<br/>create-issue.yml@main"]:::refnote
    job_on_failure__create_issue["create_issue<br/>• Build assignee list<br/>• create-an-issue"]
    job_on_failure__ref ~~~ job_on_failure__create_issue
  end
  job_check -- "failure" --> job_on_failure
  subgraph job_trigger_release ["trigger-release"]
    direction TB
    job_trigger_release__ref["calls<br/>FlorianSchw/<br/>package-workflows<br/>trigger-release-<br/>publish.yml@main"]:::refnote
    job_trigger_release__dispatch["dispatch<br/>• Dispatch release-publish"]
    job_trigger_release__ref ~~~ job_trigger_release__dispatch
  end
  job_on_success -- "success" --> job_trigger_release
  wf_release_publish_yml(["Publish Release<br/>release-publish.yml"])
  job_trigger_release -. "dispatch: release-publish" .-> wf_release_publish_yml
  classDef refnote stroke-dasharray: 4 3
```
<!-- workflow-graphs:detail:release-trigger.yml:end -->

<!-- workflow-graphs:detail:require-head-branch.yml:start -->
### Require Head Branch

<sub>`require-head-branch.yml`</sub>

```mermaid
flowchart TD
  start(["PR into main"])
  subgraph job_require_head_branch ["require-head-branch"]
    direction TB
    job_require_head_branch__ref["calls<br/>FlorianSchw/<br/>package-workflows<br/>require-head-<br/>branch.yml@main"]:::refnote
    job_require_head_branch__verify_source_branch["verify-source-branch<br/>• Verify PR source branch"]
    job_require_head_branch__ref ~~~ job_require_head_branch__verify_source_branch
  end
  start --> job_require_head_branch
  classDef refnote stroke-dasharray: 4 3
```
<!-- workflow-graphs:detail:require-head-branch.yml:end -->

<!-- workflow-graphs:detail:test-suggest.yml:start -->
### Test setup suggestions

<sub>`test-suggest.yml`</sub>

```mermaid
flowchart TD
  start(["PR into dev<br/>Monthly (day 1)<br/>Manual run"])
  subgraph job_suggest_docs ["suggest-docs"]
    direction TB
    job_suggest_docs__ref["calls<br/>FlorianSchw/<br/>package-workflows<br/>test-suggest.yml@main"]:::refnote
    job_suggest_docs__suggest_tests["suggest-tests<br/>not for bot-suggest/<br/>branches<br/>• Checkout shared scripts<br/>• Determine files to check<br/>• Get Anthropic access<br/>token<br/>• Run test suggestion<br/>script<br/>• Resolve push token<br/>• Commit generated tests"]
    job_suggest_docs__ref ~~~ job_suggest_docs__suggest_tests
  end
  start --> job_suggest_docs
  subgraph job_keepalive ["keepalive"]
    direction TB
    job_keepalive__ref["calls<br/>FlorianSchw/<br/>package-workflows<br/>workflow-<br/>keepalive.yml@main<br/>only on schedule"]:::refnote
    job_keepalive__keepalive["keepalive<br/>• gh-workflow-keepalive"]
    job_keepalive__ref ~~~ job_keepalive__keepalive
  end
  start --> job_keepalive
  classDef refnote stroke-dasharray: 4 3
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
    job_workflow_graphs__ref["calls<br/>FlorianSchw/<br/>package-workflows<br/>workflow-graphs.yml@main"]:::refnote
    job_workflow_graphs__workflow_graphs["workflow-graphs<br/>• Checkout shared scripts<br/>• Draw workflow diagrams<br/>• Resolve push token<br/>• Commit the README"]
    job_workflow_graphs__ref ~~~ job_workflow_graphs__workflow_graphs
  end
  start --> job_workflow_graphs
  classDef refnote stroke-dasharray: 4 3
```
<!-- workflow-graphs:detail:workflow-graph.yml:end -->
