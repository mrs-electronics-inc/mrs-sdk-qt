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

### Creating New Issues

Creating new issues is highly encouraged, whether it's feature ideas, newly discovered bugs, potential refactors, or something else. Even if your idea isn't very high-priority, creating an issue to leave on the backburner is better than letting the idea slip through the cracks.

When you create an issue, try your best to do the following:

- Give it a properly formatted title according to the [conventional commit standard](https://github.com/pvdlg/conventional-commit-types?tab=readme-ov-file#commit-types)
- Set the issue type based on the title's prefix
- Flesh out the different parts of the description

MAKE SURE you assign the issue to the `MRS SDK` GitHub project.

Once you have created the issue, tag a maintainer to let them know it was created so that they can triage the new issue appropriately.

#### Issue Priorities

Here is an outline of what the different issue priorities mean and when they should be used. They are listed from highest to lowest priority.

- `Hot Fix`: critical bugs that need fixed immediately. These issues will require a patch release as soon as the code changes are completed and merged.
- `Must Have`: issues that are required for the upcoming release.
- `Important`: issues that would be nice to have for the upcoming release but are not required. If they get pushed back to a future release it's not a big deal. However, we don't want these to get pushed back over and over again.
- `Normal`: issues that have no real priority. These are backburner ideas that we'll get to eventually, but at the moment they're not important.

#### Issue Weight

The weight of an issue is a loose measure of how much development time it will take to complete based on its complexity/difficulty.

One weight is equal to approximately 4 hours of development, or half a day's work.

If an issue's weight is greater than or equal to `4`, or 2 days' worth of work, then it should probably be split into multiple smaller issues. Please tag a maintainer if this is the case.

#### Issue Milestones

In this project, each milestone corresponds to an upcoming release. All issues desired for a release should be assigned to its milestone.

The project managers will take care of assigning issues to the correct milestones. DO NOT change an issue to another milestone yourself.

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
- Issue is assigned to the `MRS SDK` GitHub project, and has a status, priority, weight, and (optional) deadline
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

As you develop code for each item in the proposal checklist, check that item off of the list so that maintainers can see how you're progressing.

### In-Review Issues

Once you have a PR ready for review, move the issue to the `In Review` status. The issue should stay in this status until the PR has been merged.

If your issue requires multiple PRs, which is possible for larger issues, then move it back to `In Progress` after the current one is merged so that we know it's still in development.

### Completing an Issue

Once the PR for your issue has been merged, verify that all acceptance criteria for the issue have been met. If everything is completed then you can move the issue to the `Done` status. Doing so will automatically mark it as closed.

## Development Workflow

This section outlines the general process for development of new code in this project.

### Git Branching

As of now, all repos in this project utilize the trunk-based branching strategy. The `main` branch is the default branch, and all other branches are created from `main`.

When you begin work on an issue, create a branch off of `main`. The branch name should follow the pattern `<issue-num>-<issue-title>`.

```bash
git checkout main
git pull origin main
# Example branchname from an old issue
git checkout -b 3-docs-astro-site
```

### Writing New Code

When developing new code in your feature branch, make sure to commit often so that your progress is saved. All commits should follow the conventional commit standard in the same way as issue titles. See [this page](https://github.com/pvdlg/conventional-commit-types?tab=readme-ov-file#commit-types) for reference. You do not need to push on every commit but it is recommended to push often, especially if you have a draft PR.

As you develop your code, make sure to add plenty of comments explaining what's going on. Add an issue number on particularly complicated pieces of the implementation so that our future selves can see the full context of the code.

If you notice something else in the codebase that needs refactored or represents a bug, add a `TODO` comment and create an issue for it.

This code snippet provides an example of how to include issue numbers:

```cpp
bool MyClass::myFunction() 
{
    // This guard clause makes initial checks on some potential security vulnerabilities.
    // See #206 for more information.
    if (... extremely complicated guard clause) 
    {
        return false;
    }

    // Open the network configuration files and read the parameters for SSH connections.
    // TODO(#507): verify that the files exist before trying to open them.
    ... rest of function
    return true;
}
```

### Creating PRs

Pull requests are the standard way for your new code to be reviewed by others.

There are two ways to approach PRs. You can either create a PR immediately after pushing your first commit to the feature branch, or wait until all the code is ready. We encourage devs to create PRs early in the development process because it provides a clean way to ping others with questions you might have about a particular piece of code before submitting it for review. It also allows you to take full advantage of the automated code review bot, which runs each time you push new commits to the PR.

If you create a PR before your code is ready for review, MAKE SURE that your PR is marked as `draft` until all code changes are ready. Do not assign anyone to review until the PR is marked `ready`.

Before marking a PR as `ready`, verify the following:

- The project compiles fine in your local environment
- All coding conventions are followed
- All merge conflicts are resolved
- All GitHub Actions checks are passing
- The PR title follows conventional commit formatting
- Summary of changes and list of test steps are provided in the PR description

Once your PR is marked `ready`, assign a maintainer to review it. More details on the code review process are found in the next section.

## Code Review Expectations

This section outlines the general process for code review in this project. We have some ground rules for how interactions between assignees and reviewers should take place.
