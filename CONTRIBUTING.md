# Contributor Manual

Contributions from others are more than welcome here! This project is open-source in order to facilitate integration, customization, and improvement of our SDK for you and your hardware setup.

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

All new SDK issues should be assigned to this project. The defaults should be `Planning` for status and `Normal` for priority. The maintainers will look at the new issue and triage it appropriately.

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

The maintainers will take care of assigning issues to the correct milestones. DO NOT change an issue to another milestone yourself.

### Beginning Work on an Issue

Before working on an issue that is assigned to you, make sure that the following things have all been completed:

- Issue has a properly formatted title with a [conventional commit type](https://github.com/pvdlg/conventional-commit-types?tab=readme-ov-file#commit-types)
- Issue type is appropriately set based on the issue title
- Issue is assigned to the `MRS SDK` GitHub project, and has a status, priority, weight, and (optional) deadline
- Issue has a properly fleshed out description:
  - Background info, benefits of the change: how did this issue come about? Why do we need to implement it?
  - _For bugs only_: steps to reproduce the issue, relevant environment/context info (if applicable)
  - Proposal (checklist): what things in the code need to change in order to complete this issue?
  - Acceptance criteria (checklist): what criteria must be met from a user's standpoint for this issue to be completed?
    - This is useful for QA testing prior to releases

Most of the time an issue will have status `Planning` until these things are completed, but this is a good checklist to make sure it's really ready for development.

If all of these things are done, then move the issue to the `In Progress` status and begin development.

### In-Progress Issues

An issue should stay in status `In Progress` until you have a pull request that is ready for review.

If you discover that something in the issue description needs changed/updated, feel free to do so, but make sure that large revisions are vetted by a maintainer before you continue development. This helps avoid scope creep. You can get a PM's input by tagging them in a comment on the issue.

As you develop code for each item in the proposal checklist, check that item off of the list so that maintainers can see how you're progressing.

### In-Review Issues

Once you have a PR ready for review, move the issue to the `In Review` status. The issue should stay in this status until the PR has been merged.

If your issue requires multiple PRs, which is possible for larger issues, then move it back to `In Progress` after the current one is merged so that we know it's still in development.

### Completing an Issue

Once the PR for your issue has been merged, verify that all acceptance criteria for the issue have been met. If everything is completed then you can move the issue to the `Done` status. Doing so will automatically mark it as closed.

## Development Workflow

This section outlines the general process for development of new code in this project.

### Git Branching

This repo utilizes the trunk-based branching strategy. The `main` branch is the default branch, and all other branches are created from `main`.

When you begin work on an issue, create a branch off of `main`. The branch name should follow the pattern `<issue-num>-<issue-title>`.

```bash
git checkout main
git pull origin main
# Example: check out a branch for issue #3
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
    // ... rest of function
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

Do not assign the PR to a GitHub project. Those are meant for issues only.

Once your PR is marked `ready`, assign a maintainer to review it. More details on the code review process are found in the next section.

## Code Review Guidelines

This section outlines the general process for code review in this project. We have some ground rules for how interactions between authors and reviewers should take place.

### Reviewing Others' Code

When someone else requests your review on a PR, try to **do so in a timely manner**. The longer PRs stay open, the more likely they are to have merge conflicts, and it also prevents the author from moving on to other issues.

Here are the steps for reviewing code:

1. Go through the test steps in the PR description.
2. If any of the tests fail, then submit your review with changes requested and a comment indicating which test failed and what exactly went wrong.
   - Be as specific as possible about what failed. Include the exact steps you took and any relevant debug output.
   - Mark the PR as `draft` so that it cannot be accidentally merged.
3. Do your best to test scenarios that may not be explicitly listed in the PR description.
4. If all testing passes, then move to reviewing the implementation.
   - Keep in mind, you are only reviewing the test cases in the PR description. Do not request changes if a PR does not meet the acceptance criteria in the issue. It's possible that the dev plans to implement those changes in another PR.
5. Make comments/suggestions on any places in the code where you have concerns or see room for improvement.
   - Use the **Start a review** button to add comments so that none of them are published until you submit your review.
6. Once you have finished reviewing the code, submit your review.
   - If there are things that need changed, then summarize what needs changed and request changes. Mark the PR as `draft` after doing so.
   - If everything looks good, then approve the PR.

If you requested changes, then wait for the author to re-request your review and mark the PR as `ready` again. Once they do that, repeat these steps. This cycle should continue as many times as needed until the PR is ready for merge.

### Change Requests on Your Code

Once you have submitted your code for review, there is nothing else that needs done on your end until the reviewer finishes their review.

Here are the steps for responding to change requests on your code:

1. If the reviewer found bugs or failed tests, go through the steps they provided for reproducing each bug. Resolve those problems first.
2. If the reviewer requested code improvements, and they were not made obselete by bugfixes, then implement the requests.
3. Mark the PR as `ready` and re-request review so that the reviewer knows the code is ready for a second round of review.

### Merging PRs

Once a PR has all of the necessary approvals (and all Actions checks are passing) then it is ready to be merged. All merges should be done by the reviewers/project maintainers.

All PRs should be merged via squash-merging, and the feature branch should be deleted after it is merged.

After your PR is merged, then the issue can be [updated appropriately](#completing-an-issue).
