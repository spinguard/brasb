# Codebase Maintenance

This article describes how to maintain the codebase associated with the BRASB course.

Note that the codebase is actually a sequence of commits packages as a standalone repo,
each commit aligns with one or more lab lessons,
and provides start and solution points for each lab (workshop).

There are several reasons for handling the codebase this way,
versus exploding start and stop points for each lab (workshop):

- The author can visualize the project across lessons,
  and do cross cutting maintenance or upgrade edits much more efficiently using standard git
  patterns.
- Exploding build tool wrappers for each individual lab (workshop) is wasteful of git resources.
- The student can easily view or cherry-pick the solution points,
  or reset to the start points using standard git commands/patterns.
  The student can also access the public repo releases and experiment on their own.

## Branches

The educational content, tooling and workflows exist in `main` or `develop` branches,
and subject to traditional trunk or PR-based github flows.

The lab codebase does not exist in the `main` or `develop` branches,
as the unit of release is actually the sequence of start/stop point commits
in isolated (orphaned) branches, and associated with multiple labs.

The lab codebase branches are handled as follows:

- `codebase-develop` branches are used to build out and stage a series of commits
  that will be released to a `codebase-release-vM.m.p(-hf)` branch
  - A default `codebase-develop` branch, but not protected against force pushes
  - PR type flows should include external contributions with branch prefix of `codebase-develop-`
  - PR flow type merge changes back to `codebase-develop`

- `codebase-release-vM.m.p(-hf)` branches are used to provide version history,
  and a staging point for tagged release artifacts.

- Releases include tagged commits for the last commit in a given *release*
  branch, as well as `zip` and `tar.gz` artifacts published with the associated
  tag.

- Commits include a prefix in a commit message to uniquely identify the commit in
  a branch.
  In this doc, it may be referred to as *commit-title* or *lesson-label* depending on context.
  The reason for this is that git commits are immutable,
  and when editing a history (using rebasing), the shas will change.

## Author Flows

### Add new lab/commits

If the author wishes to add new labs with start/stop commit points,
they can treat the codebase as a usual git development floe.

The latest commit and changes on the codebase can be viewed by changing workspace
to the `codebase-develop` branch:

```bash
git checkout codebase-develop
```

The author can add new commits at the end of the branch, commit, and push them.

The history of the codebase can be viewed:

```bash
git log --oneline
```

### Editing existing commits

Rebasing or regenerating the `codebase-develop` branch is the method
to change the entire codebase (series of commits).

These types of changes originate in the local authors git workspace,
where git rebase is likely to be used:

- Find the appropriate commit from list of commits - `git log --oneline`

- Edit starting at commit - `git rebase -i <commit>`

- Make the appropriate changes and test them for the appropriate lab (workshop).

- If merge conflicts are encountered, must resolve then stage
  and continue rebase:

  ```bash
  git add <resolved resource>
  git rebase --continue
  ```

Note: when rebasing or ammending commits, git will generate new shas.
That means even commits in a rebase sequence that are fast-forwarded will
get new shas, because technically they are a "new" history.
For this reason, it is strongly recommended the author uses the git commit
message as a unique qualifer for a commit in a branch:

- *commit-title*: a unique qualifier key embedded in a git commit message.
- *lesson-label*: a lookup key embedded in a git commit message that can be used in
  a lesson/lab to checkout to a commit associated with a particular lab or lesson.

While these are different concepts, they use the same solution:

Imbed a unique title within arrow brackets (`<>`) at the front of the commit message
when applying it.

If the author is editing a single commit in a branch,
they can use the `git-edit-commit-by-title <commit-title>` script to initiate the rebase
without having to run git log to navigate the appropriate commit to initiate the edit.

### PR editing flow

PR can also be used by checking out a topic branch from `codebase-develop` with the target
merge branch back to it.

Given the branch is not force-push protected, there are no special considerations for merging
to the `codebase-develop` branch (other than thorough review)

### Testing

A convenience script is provided to test all the commits in the codebase:

`scripts/codebase/test-codebase`

### Restore codebase

An occasional scenario for authoring might be to restore either a topic branch
or a particular *codebase-release-v(M).(m).(p)[-(hf)]*
branch to the `codebase-develop` branch or associated PR topic branch.

This may occur when an author inadvertantly rebases/edits the `codebase-develop` incorrectly,
and cannot recover it.

Assuming the author has not yet pushed the changed,
they can recover locally:

```bash
git branch -D codebase-develop
scripts/codebase/clone-branch <source branch name> codebase-develop
```

## Consumer flows

The consumer flow is simple:

1. Download the appropriate release artifact from the
   [Releases page](https://github.com/spinguard/brasb-git-author-poc/releases).

1. Extract to the file system where the git repo workspace will be used.

1. Navigate to the appropriate commit - `git checkout <appropriate sha>`, or
   use the convenience scripts:
   - `checkout-to-commit-title <commit-title> <repo directory>` primarily for author testing a release
   - `01-stage-codebase.sh` used primarily for Educates flows where repo is staged in a workshop,
     and the assocated environment variables set the repo and *lesson-label*.
     It can be copied or otherwise staged to the associated `setup.d` folders in the workshop content
     folders.

## Release Process

The release process is semi-automated in the `.github/workflows/release-codebase.yml`
Github Actions workflow:

- Calculate the new release version (if automatic)
  - Given whether the change is `major`, `minor`, `patch`, or `hotfix`, or manually calculated.
  - Detect existing semantic version branches.
  - New release branch will increment the approach semantic version
    according to `v(Major).(Minor).(Patch)-(HotFix)`, or `v(M).(m).(p)[-(hf)]` for short.
    Note that if the hotfix is ommitted,
    the suffix will not be included as part of the semantic version.

- The `codebase-develop` branch is "copied" to a newly created *codebase-release-v(M).(m).(p)[-(hf)]* branch:
  - The new branch is named according to the previously provided version
    (auto or manually created), incremented by either major,
    minor, patch, or (optional) hotfix suffix.
  - The new branch is orphaned with an empty commit.
  - The commits of the `codebase-develop` branch are cherry-picked into
    the *codebase-release-v(M).(m).(p)[-(hf)]* branch.

- The last commit of the *codebase-release-v(M).(m).(p)[-(hf)]* branch is tagged with the semantic
  version number - this is for an author's navigational convenience.

- The *codebase-release-v(M).(m).(p)[-(hf)]* branch and tag are pushed to the Github remote.

- The *codebase-release-v(M).(m).(p)[-(hf)]* branch is published in github:
  - Both `zip` and `tar.gz` artifacts are created including a git repository
    with *only* the commits of the newly created release branch,
    and the associated release tag.

- The *codebase-release-v(M).(m).(p)[-(hf)]* branch is lock protected (making it immutable).
  This ensures at worse case if the `codebase-develop` branch is inadvertantly deleted,
  it can be recovered to the last release codebase.