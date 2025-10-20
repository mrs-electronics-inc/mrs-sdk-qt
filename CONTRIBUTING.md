# Contributor Manual

Contributions from others are more than welcome here! This is an open-source project, after all. While we do use this product for commercial purposes, we also want it to be a helpful resource to the open-source community!

## Getting Started

Follow these instructions to install the necessary components on your system for development of the SDK.

### Install Qt

Refer to [this page](https://qt.mrs-electronics.dev/guides/installation) on how to do it. You'll need the cross-compiler toolchains for our Buildroot and Yocto operating systems, so it's not just a vanilla Qt installation.

### Set Up Repo

```bash
# Clone repo.
git clone https://github.com/mrs-electronics-inc/mrs-sdk-qt.git
cd mrs-sdk-qt
# Set up submodules.
git submodule update --init --recursive
```

## Issue Workflow

We have some conventions for the issue workflow in this project that we expect all contributors to adhere to.

### GitHub Project

All issues in the SDK project are managed from [this GitHub project](https://github.com/orgs/mrs-electronics-inc/projects/4/views/1).

All new SDK issues should be assigned to this project. The defaults should be `Planning` for status and `Normal` for priority. The project managers will look at the new issue and triage it appropriately.

**This GitHub project is the single source of truth for project status.** So, we expect all contributors to update their issues as work progresses to ensure that the GitHub project is always up-to-date.

### Choosing an Issue to Work

**Do NOT work on any issues that are not assigned to you.** If you have no issues assigned to you, communicate that to a project manager. Do not assign yourself to issues without a PM's approval.

Once you have a few issues assigned to you that are ready for work, prioritize them as follows:

1. If the issue has a due date, MAKE SURE it is done by that date. Issues are not required to have a due date so there must be a pretty good reason for it to have one.
2. Work on higher-priority issues before lower-priority issues. If you have an issues marked as 'Hot Fix' then it should be worked ASAP.
3. Work on issues assigned to the next upcoming milestone before working on issues for future milestones.
4. Work on "heavier" (higher weight) issues before "lighter" (lower weight) issues. These "heavier" issues are typically more important, and it is good to start on them sooner rather than later because of the longer development time.

### Beginning Work on an Issue

Before working on an issue that is assigned to you, make sure that the following things have all been completed:

- Issue has a properly formatted title with a [conventional commit type](https://github.com/pvdlg/conventional-commit-types?tab=readme-ov-file#commit-types)
- Issue type is appropriately set based on the issue title
- Issue is assigned to the `MRS SDK` project, and has a status, priority, weight, and (optional) deadline
- Issue has a properly fleshed out description:
  - Background info, benefits of the change: how did this issue come about? Why do we need to implement it?
  - *For bugs only*: steps to reproduce the issue, relevant environment/context info (if applicable)
  - Proposal (checklist): what things in the code need to change in order to complete this issue?
  - Acceptance criteria (checklist): what criteria must be met from a user's standpoint for this issue to be completed?
    - This is useful for QA testing prior to releases

Most of the time an issue will have status `Planning` until these things are completed, but this is a good checklist to make sure it's really ready for development.

If all of these things are done, then move the issue to the `In Progress` status and begin development.

### In-Progress Issues

An issue should stay in status `In Progress` until you have a pull request that is ready for review.

If you discover that something in the issue description needs changed/updated, feel free to do so, but make sure that large revisions are vetted by a project manager before you continue development. This helps avoid scope creep. You can get a PM's input by tagging them in a comment on the issue.

### In-Review Issues

Once you have a PR ready for review, move the issue to the `In Review` status. The issue should stay in this status until the PR has been merged.

If your issue requires multiple PRs, which is possible for larger issues, then move it back to `In Progress` after the current one is merged so that we know it's still in development.

### Completing an Issue

Once the PR for your issue has been merged, verify that all acceptance criteria for the issue have been met. If everything is completed then you can move the issue to the `Done` status. Doing so will automatically mark it as closed.

## Development Workflow

This section outlines the general process for development of new code in this project.

## Code Review Conventions

This section outlines the general process for code review in this project. We have some ground rules for how interactions between assignees and reviewers should take place.
