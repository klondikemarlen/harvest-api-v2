# Harvest API V2 Feature Workflow

## Feature completion

1. Create or identify the GitHub issue with the user story and acceptance criteria.
2. Create an issue-named branch from `main` before editing. If scoped work already exists, create the branch before committing.
3. Make the smallest change that satisfies the issue. Add or update behavior tests and keep the public README accurate.
4. Run `ruby test_harvest_api_v2.rb` and `gem build marlens-harvest-api-v2.gemspec` locally. Delete the generated `.gem` after this pre-PR build check.
5. Open a draft PR linked to the issue. Record the exact checks run; mark it ready only after the acceptance criteria and verification pass.
6. Merge the reviewed PR into `main`. Rebase or update local `main` before releasing.

## Release and publish

1. For releasable behavior, update `Marlens::HarvestApiV2::VERSION` before opening the release PR. Do not publish an unmerged branch.
2. On merged `main`, build `marlens-harvest-api-v2-<version>.gem` with `gem build marlens-harvest-api-v2.gemspec`.
3. Publish exactly that artifact with `gem push marlens-harvest-api-v2-<version>.gem`.
4. Tag the merged release as `v<version>` and create the GitHub release.
5. Verify the version remotely with `gem list --remote marlens-harvest-api-v2 --exact --all`. If RubyGems is stale, verify `https://rubygems.org/api/v2/rubygems/marlens-harvest-api-v2/versions/<version>.json`.
6. Install the published gem into a temporary `GEM_HOME` and smoke-check `ruby -e 'require "marlens/harvest_api_v2"; puts Marlens::HarvestApiV2::VERSION'`.
7. Delete the local `.gem` artifact and any one-off smoke helper before committing follow-up work.
