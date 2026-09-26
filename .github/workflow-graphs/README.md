# Workflows

The GitHub Actions workflows of this repository, and how they connect.
The diagrams are generated from the workflow files by
[workflow-graphs](https://github.com/FlorianSchw/package-workflows) and
updated when the workflows change. Text outside the marked diagram
blocks is yours: add explanations anywhere, it is never overwritten.

## Overview

<!-- workflow-graphs:overview:start -->
```mermaid
flowchart LR
  ev_1(["PR into dev"]) --> lane_1
  subgraph lane_1 [" "]
    direction TB
    wf_check_author_included_yml["Update DESCRIPTION Authors<br/><small>check-author-included.yml</small>"]
    wf_commitlint_yml["Commit compatibility check<br/><small>commitlint.yml</small>"]
    wf_docs_suggest_yml["Roxygen Doc Suggestions<br/><small>docs-suggest.yml</small><br/><small>only R/** · also: monthly (day 1) · manual</small>"]
    wf_R_CMD_Check_yml["R CMD Check<br/><small>R-CMD-Check.yml</small><br/><small>only R/**, tests/** (+3) · also: weekly (Mon) · manual</small>"]
    wf_test_suggest_yml["Test setup suggestions<br/><small>test-suggest.yml</small><br/><small>only R/** · also: monthly (day 1) · manual</small>"]
    wf_workflow_graph_yml["Workflow Graphs<br/><small>workflow-graph.yml</small><br/><small>only .github/workflows/** · also: push to dev · manual</small>"]
  end
  ev_2(["PR closed"]) --> lane_2
  subgraph lane_2 [" "]
    direction TB
    wf_cleanup_suggestion_branch_yml["Cleanup Suggestion Branch<br/><small>cleanup-suggestion-branch.yml</small>"]
  end
  ev_3(["PR into main"]) --> lane_3
  subgraph lane_3 [" "]
    direction TB
    wf_release_trigger_yml["Release<br/><small>release-trigger.yml</small>"]
    wf_require_head_branch_yml["Require Head Branch<br/><small>require-head-branch.yml</small>"]
  end
  ev_4(["Dispatch: release-publish"]) --> lane_4
  subgraph lane_4 [" "]
    direction TB
    wf_release_publish_yml["Publish Release<br/><small>release-publish.yml</small>"]
  end
  wf_release_trigger_yml -. "dispatch: release-publish" .-> wf_release_publish_yml
```
<!-- workflow-graphs:overview:end -->

## Workflows

<!-- workflow-graphs:detail:check-author-included.yml:start -->
### Update DESCRIPTION Authors

<sub>`check-author-included.yml`</sub>

```mermaid
flowchart LR
  start(["PR into dev"])
  job_check_authors["check-authors<br/><small>FlorianSchw/package-workflows › authors-suggest.yml@main</small>"]
  start --> job_check_authors
```
<!-- workflow-graphs:detail:check-author-included.yml:end -->

<!-- workflow-graphs:detail:cleanup-suggestion-branch.yml:start -->
### Cleanup Suggestion Branch

<sub>`cleanup-suggestion-branch.yml`</sub>

```mermaid
flowchart LR
  start(["PR closed"])
  job_cleanup["cleanup<br/><small>FlorianSchw/package-workflows › cleanup-suggestion-branch.yml@main</small>"]
  start --> job_cleanup
```
<!-- workflow-graphs:detail:cleanup-suggestion-branch.yml:end -->

<!-- workflow-graphs:detail:commitlint.yml:start -->
### Commit compatibility check

<sub>`commitlint.yml`</sub>

```mermaid
flowchart LR
  start(["PR into dev"])
  job_commitlint["commitlint<br/><small>FlorianSchw/package-workflows › commitlint.yml@main</small>"]
  start --> job_commitlint
```
<!-- workflow-graphs:detail:commitlint.yml:end -->

<!-- workflow-graphs:detail:docs-suggest.yml:start -->
### Roxygen Doc Suggestions

<sub>`docs-suggest.yml`</sub>

```mermaid
flowchart LR
  start(["PR into dev · Monthly (day 1) · Manual run"])
  job_suggest_docs["suggest-docs<br/><small>FlorianSchw/package-workflows › roxygen-suggest.yml@main</small>"]
  start --> job_suggest_docs
  job_keepalive["keepalive<br/><small>FlorianSchw/package-workflows › workflow-keepalive.yml@main</small><br/><small>if: github.event_name == 'schedule'</small>"]
  start --> job_keepalive
```
<!-- workflow-graphs:detail:docs-suggest.yml:end -->

<!-- workflow-graphs:detail:R-CMD-Check.yml:start -->
### R CMD Check

<sub>`R-CMD-Check.yml`</sub>

```mermaid
flowchart LR
  start(["PR into dev · Weekly (Mon) · Manual run"])
  job_check["check<br/><small>FlorianSchw/package-workflows › r-cmd-check.yml@main</small>"]
  start --> job_check
  job_keepalive["keepalive<br/><small>FlorianSchw/package-workflows › workflow-keepalive.yml@main</small><br/><small>if: github.event_name == 'schedule'</small>"]
  start --> job_keepalive
```
<!-- workflow-graphs:detail:R-CMD-Check.yml:end -->

<!-- workflow-graphs:detail:release-publish.yml:start -->
### Publish Release

<sub>`release-publish.yml`</sub>

```mermaid
flowchart LR
  start(["Dispatch: release-publish"])
  job_release["release<br/><small>FlorianSchw/package-workflows › package-release.yml@main</small>"]
  start --> job_release
```
<!-- workflow-graphs:detail:release-publish.yml:end -->

<!-- workflow-graphs:detail:release-trigger.yml:start -->
### Release

<sub>`release-trigger.yml`</sub>

```mermaid
flowchart LR
  start(["PR into main"])
  job_check["check<br/><small>FlorianSchw/package-workflows › r-cmd-check.yml@main</small><br/><small>if: github.head_ref == 'dev'</small>"]
  start --> job_check
  job_on_success["on-success<br/><small>FlorianSchw/package-workflows › merge-pull-request.yml@main</small>"]
  job_check -- "success" --> job_on_success
  job_on_failure["on-failure<br/><small>FlorianSchw/package-workflows › create-issue.yml@main</small>"]
  job_check -- "failure" --> job_on_failure
  job_trigger_release["trigger-release<br/><small>FlorianSchw/package-workflows › trigger-release-publish.yml@main</small>"]
  job_on_success -- "success" --> job_trigger_release
  wf_release_publish_yml(["Publish Release<br/><small>release-publish.yml</small>"])
  job_trigger_release -. "dispatch: release-publish" .-> wf_release_publish_yml
```
<!-- workflow-graphs:detail:release-trigger.yml:end -->

<!-- workflow-graphs:detail:require-head-branch.yml:start -->
### Require Head Branch

<sub>`require-head-branch.yml`</sub>

```mermaid
flowchart LR
  start(["PR into main"])
  job_require_head_branch["require-head-branch<br/><small>FlorianSchw/package-workflows › require-head-branch.yml@main</small>"]
  start --> job_require_head_branch
```
<!-- workflow-graphs:detail:require-head-branch.yml:end -->

<!-- workflow-graphs:detail:test-suggest.yml:start -->
### Test setup suggestions

<sub>`test-suggest.yml`</sub>

```mermaid
flowchart LR
  start(["PR into dev · Monthly (day 1) · Manual run"])
  job_suggest_docs["suggest-docs<br/><small>FlorianSchw/package-workflows › test-suggest.yml@main</small>"]
  start --> job_suggest_docs
  job_keepalive["keepalive<br/><small>FlorianSchw/package-workflows › workflow-keepalive.yml@main</small><br/><small>if: github.event_name == 'schedule'</small>"]
  start --> job_keepalive
```
<!-- workflow-graphs:detail:test-suggest.yml:end -->

<!-- workflow-graphs:detail:workflow-graph.yml:start -->
### Workflow Graphs

<sub>`workflow-graph.yml`</sub>

```mermaid
flowchart LR
  start(["Push to dev · PR into dev · Manual run"])
  job_workflow_graphs["workflow-graphs<br/><small>FlorianSchw/package-workflows › workflow-graphs.yml@main</small>"]
  start --> job_workflow_graphs
```
<!-- workflow-graphs:detail:workflow-graph.yml:end -->
