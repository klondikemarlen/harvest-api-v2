# Marlens Harvest API V2

Small Ruby client for the Harvest API V2. It uses Ruby's standard library and exposes `Marlens::HarvestApiV2::Client#request` plus the task-assignment and duration-time-entry calls used by the companion `harvest-time-off` CLI.

```ruby
require "marlens/harvest_api_v2"
client = Marlens::HarvestApiV2::Client.from_environment
client.create_time_entry(
  project_id: 48_730_683,
  task_id: 8_083_365,
  spent_date: Date.new(2026, 7, 15),
  hours: 7.5,
  notes: "Vacation"
)
```

Set `HARVEST_ACCESS_TOKEN` and `HARVEST_ACCOUNT_ID`; the client does not read credential files.

## Feature and release workflow

Follow [`docs/workflows/feature-workflow.md`](docs/workflows/feature-workflow.md): issue and acceptance criteria, issue branch, tested draft PR, reviewed merge to `main`, version bump, RubyGems publish, remote verification, and isolated install smoke test.
