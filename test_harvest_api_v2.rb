# frozen_string_literal: true

require "date"
require "json"
require "minitest/autorun"
require "net/http"
require "uri"

$LOAD_PATH.unshift File.expand_path("lib", __dir__)
require "harvest_api_v2"

class HarvestApiV2Test < Minitest::Test
  def test_lists_active_task_assignments_with_harvest_headers
    requests = []
    client = HarvestApiV2::Client.new(
      access_token: "test-token",
      account_id: "123",
      executor: ->(request) do
        requests << request
        response(200, task_assignments: [{ project: { id: 48_730_683 }, task: { id: 8_083_365 } }])
      end
    )

    assignments = client.active_task_assignments

    assert_equal [{ "project" => { "id" => 48_730_683 }, "task" => { "id" => 8_083_365 } }], assignments
    assert_equal "Bearer test-token", requests.first["Authorization"]
    assert_equal "123", requests.first["Harvest-Account-Id"]
    assert_equal({ "is_active" => "true", "per_page" => "2000" }, URI.decode_www_form(requests.first.uri.query).to_h)
  end

  def test_creates_duration_time_entry
    requests = []
    client = HarvestApiV2::Client.new(
      access_token: "test-token",
      account_id: "123",
      executor: ->(request) do
        requests << request
        response(201, id: 123_456)
      end
    )

    entry = client.create_time_entry(
      project_id: 48_730_683,
      task_id: 8_083_365,
      spent_date: Date.new(2026, 7, 15),
      hours: 7.5,
      notes: "Vacation"
    )

    assert_equal 123_456, entry.fetch("id")
    assert_equal(
      { "project_id" => 48_730_683, "task_id" => 8_083_365, "spent_date" => "2026-07-15", "hours" => 7.5, "notes" => "Vacation" },
      JSON.parse(requests.first.body)
    )
  end

  def test_surfaces_harvest_error_message
    client = HarvestApiV2::Client.new(
      access_token: "test-token",
      account_id: "123",
      executor: ->(_request) { response(422, message: "Project is invalid") }
    )

    error = assert_raises(HarvestApiV2::Error) { client.request(:post, "/v2/time_entries", body: {}) }

    assert_equal "Project is invalid", error.message
    assert_equal "422", error.status
  end

  private

  def response(status, body)
    json = JSON.generate(body)
    response = Net::HTTPResponse::CODE_TO_OBJ.fetch(status.to_s).new("1.1", status.to_s, "OK")
    response.define_singleton_method(:body) { json }
    response
  end
end
