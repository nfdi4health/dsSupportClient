# Workflows

The GitHub Actions workflows of this repository, and how they connect.
The diagrams are generated from the workflow files by
[workflow-graphs](https://github.com/FlorianSchw/package-workflows) and
updated when the workflows change. Text outside the marked diagram
blocks is yours: add explanations anywhere, it is never overwritten.

<!-- workflow-graphs:overview:start -->
## All workflows

| Name | File | Runs on | Calls | Produces |
|---|---|---|---|---|
| Update DESCRIPTION Authors | `check-author-included.yml` | PR into dev | nfdi4health/datashield-workflows › authors-suggest.yml@v1/foundation | • Suggestion PR<br>• Comment on the PR — *only if: pull request* |
| Commit compatibility check | `commitlint.yml` | PR into dev | nfdi4health/datashield-workflows › commitlint.yml@v1/foundation | Check: commit messages follow Conventional Commits |
| Roxygen Doc Suggestions | `docs-suggest.yml` | • PR into dev (only if: R/\*\* changed)<br>• Monthly (day 1)<br>• Manual run | • nfdi4health/datashield-workflows › roxygen-suggest.yml@v1/foundation<br>• nfdi4health/datashield-workflows › workflow-keepalive.yml@v1/foundation | • Suggestion PR<br>• Comment on the PR — *only if: pull request*<br>• Scheduled workflows kept enabled — *only if: scheduled run* |
| R CMD Check | `R-CMD-Check.yml` | • PR into dev (only if: R/\*\*, tests/\*\*, .github/\*\*, DESCRIPTION, NAMESPACE changed)<br>• Weekly (Mon)<br>• Manual run | • nfdi4health/datashield-workflows › r-cmd-check.yml@v1/foundation<br>• nfdi4health/datashield-workflows › workflow-keepalive.yml@v1/foundation | • Check: R CMD check passes<br>• Scheduled workflows kept enabled — *only if: scheduled run* |
| Test setup suggestions | `test-suggest.yml` | • PR into dev (only if: R/\*\* changed)<br>• Monthly (day 1)<br>• Manual run | • nfdi4health/datashield-workflows › test-suggest.yml@v1/foundation<br>• nfdi4health/datashield-workflows › workflow-keepalive.yml@v1/foundation | • Suggestion PR<br>• Comment on the PR — *only if: pull request*<br>• Issue for a likely bug in the code<br>• Scheduled workflows kept enabled — *only if: scheduled run* |
| Cleanup Suggestion Branch | `cleanup-suggestion-branch.yml` | PR closed | nfdi4health/datashield-workflows › cleanup-suggestion-branch.yml@v1/foundation | Bot branch deleted — *only if: PR from bot-suggest/ branches* |
| Release | `release-trigger.yml` | PR into main | • nfdi4health/datashield-workflows › r-cmd-check.yml@v1/foundation<br>• nfdi4health/datashield-workflows › merge-pull-request.yml@v1/foundation<br>• nfdi4health/datashield-workflows › create-issue.yml@v1/foundation<br>• nfdi4health/datashield-workflows › trigger-release-publish.yml@v1/foundation | • Check: R CMD check passes — *only if: PR comes from dev*<br>• PR merged — *if check succeeds*<br>• Issue for the PR author — *if check fails*<br>• starts **Publish Release** |
| Publish Release | `release-publish.yml` | Dispatch: release-publish | nfdi4health/datashield-workflows › package-release.yml@v1/foundation | Version commit, tag and draft release |
| Require Head Branch | `require-head-branch.yml` | PR into main | nfdi4health/datashield-workflows › require-head-branch.yml@v1/foundation | Check: PR comes from dev |
| Suggestion Choices | `suggestion-choices.yml` | PR edited | nfdi4health/datashield-workflows › suggestion-choices.yml@v1/foundation | — |
| Workflow Graphs | `workflow-graph.yml` | • Push to dev (only if: .github/workflows/\*\* changed)<br>• Manual run | nfdi4health/datashield-workflows › workflow-graphs.yml@v1/foundation | • Commit on the branch — *only if: push*<br>• Note on the PR: runs on push only — *only if: pull request* |

## Events

What each event starts: the workflows (bold), what they produce (dashed boxes) and the workflows they start in turn (dotted arrows). **only if:** — happens only under this condition, e.g. when these files changed; **skipped:** — doesn't happen in this case. A label on an arrow applies to that arrow only ("if check fails").

### PR into dev

*When a pull request into dev is opened or updated.*

```mermaid
%%{init: {"flowchart": {"rankSpacing": 140, "nodeSpacing": 45}}}%%
flowchart LR
  ev(["PR into dev"])
  wf_check_author_included_yml["<b>Update DESCRIPTION Authors</b>"]
  ev --> wf_check_author_included_yml
  wf_commitlint_yml["<b>Commit compatibility check</b>"]
  ev --> wf_commitlint_yml
  wf_docs_suggest_yml["<b>Roxygen Doc Suggestions</b><br/>only if: R/#42;#42; changed"]
  ev --> wf_docs_suggest_yml
  wf_R_CMD_Check_yml["<b>R CMD Check</b><br/>only if: R/#42;#42;, tests/#42;#42;,<br/>.github/#42;#42;, DESCRIPTION,<br/>NAMESPACE changed"]
  ev --> wf_R_CMD_Check_yml
  wf_test_suggest_yml["<b>Test setup suggestions</b><br/>only if: R/#42;#42; changed"]
  ev --> wf_test_suggest_yml
  out_1(["Suggestion PR"]):::outcome
  out_2(["Comment on the PR"]):::outcome
  out_3(["Check: commit messages<br/>follow Conventional<br/>Commits"]):::outcome
  out_4(["Check: R CMD check passes"]):::outcome
  out_5(["Issue for a likely bug in<br/>the code"]):::outcome
  wf_check_author_included_yml --> out_1
  wf_check_author_included_yml --> out_2
  wf_commitlint_yml --> out_3
  wf_docs_suggest_yml --> out_1
  wf_docs_suggest_yml --> out_2
  wf_R_CMD_Check_yml --> out_4
  wf_test_suggest_yml --> out_1
  wf_test_suggest_yml --> out_2
  wf_test_suggest_yml --> out_5
  classDef outcome stroke-dasharray: 4 3
```

### PR closed

*When a pull request is closed.*

```mermaid
%%{init: {"flowchart": {"rankSpacing": 140, "nodeSpacing": 45}}}%%
flowchart LR
  ev(["PR closed"])
  wf_cleanup_suggestion_branch_yml["<b>Cleanup Suggestion Branch</b><br/>only if: PR from<br/>bot-suggest/ branches"]
  ev --> wf_cleanup_suggestion_branch_yml
  out_1(["Bot branch deleted"]):::outcome
  wf_cleanup_suggestion_branch_yml --> out_1
  classDef outcome stroke-dasharray: 4 3
```

### PR into main

*When a pull request into main is opened or updated.*

```mermaid
%%{init: {"flowchart": {"rankSpacing": 70, "nodeSpacing": 40}}}%%
flowchart TD
  ev(["PR into main"])
  wf_release_trigger_yml["<b>Release</b><br/>only if: PR comes from dev"]
  ev --> wf_release_trigger_yml
  wf_require_head_branch_yml["<b>Require Head Branch</b>"]
  ev --> wf_require_head_branch_yml
  wf_release_publish_yml["<b>Publish Release</b>"]
  out_release_trigger_yml_check_1(["Check: R CMD check passes"]):::outcome
  out_release_trigger_yml_on_success_2(["PR merged"]):::outcome
  out_1(["Issue for the PR author"]):::outcome
  out_2(["Check: PR comes from dev"]):::outcome
  out_3(["Version commit, tag and<br/>draft release"]):::outcome
  wf_release_trigger_yml --> out_release_trigger_yml_check_1
  out_release_trigger_yml_check_1 -- "if check succeeds" --> out_release_trigger_yml_on_success_2
  out_release_trigger_yml_check_1 -- "if check fails" --> out_1
  out_release_trigger_yml_on_success_2 -. "dispatch: release-publish" .-> wf_release_publish_yml
  wf_require_head_branch_yml --> out_2
  wf_release_publish_yml --> out_3
  classDef outcome stroke-dasharray: 4 3
```

### PR edited

*When a pull request is edited.*

```mermaid
%%{init: {"flowchart": {"rankSpacing": 140, "nodeSpacing": 45}}}%%
flowchart LR
  ev(["PR edited"])
  wf_suggestion_choices_yml["<b>Suggestion Choices</b>"]
  ev --> wf_suggestion_choices_yml
  classDef outcome stroke-dasharray: 4 3
```

### Push to dev

*On a push to dev.*

```mermaid
%%{init: {"flowchart": {"rankSpacing": 140, "nodeSpacing": 45}}}%%
flowchart LR
  ev(["Push to dev"])
  wf_workflow_graph_yml["<b>Workflow Graphs</b><br/>only if:<br/>.github/workflows/#42;#42;<br/>changed"]
  ev --> wf_workflow_graph_yml
  out_1(["Commit on the branch"]):::outcome
  wf_workflow_graph_yml --> out_1
  classDef outcome stroke-dasharray: 4 3
```

### On a schedule

*On a schedule.*

```mermaid
%%{init: {"flowchart": {"rankSpacing": 140, "nodeSpacing": 45}}}%%
flowchart LR
  ev(["On a schedule"])
  wf_docs_suggest_yml["<b>Roxygen Doc Suggestions</b><br/>monthly (day 1)"]
  ev --> wf_docs_suggest_yml
  wf_R_CMD_Check_yml["<b>R CMD Check</b><br/>weekly (Mon)"]
  ev --> wf_R_CMD_Check_yml
  wf_test_suggest_yml["<b>Test setup suggestions</b><br/>monthly (day 1)"]
  ev --> wf_test_suggest_yml
  out_1(["Suggestion PR"]):::outcome
  out_2(["Scheduled workflows kept<br/>enabled"]):::outcome
  out_3(["Check: R CMD check passes"]):::outcome
  out_4(["Issue for a likely bug in<br/>the code"]):::outcome
  wf_docs_suggest_yml --> out_1
  wf_docs_suggest_yml --> out_2
  wf_R_CMD_Check_yml --> out_3
  wf_R_CMD_Check_yml --> out_2
  wf_test_suggest_yml --> out_1
  wf_test_suggest_yml --> out_4
  wf_test_suggest_yml --> out_2
  classDef outcome stroke-dasharray: 4 3
```
<!-- workflow-graphs:overview:end -->
