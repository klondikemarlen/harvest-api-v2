# frozen_string_literal: true

require "json"
require "net/http"
require "uri"

module Marlens::HarvestApiV2
  class Client
    API_URL = "https://api.harvestapp.com".freeze
    USER_AGENT = "marlens-harvest-api-v2/#{VERSION}".freeze

    def self.from_environment(environment: ENV)
      access_token = environment.fetch("HARVEST_ACCESS_TOKEN", "")
      account_id = environment.fetch("HARVEST_ACCOUNT_ID", "")
      raise Error, "HARVEST_ACCESS_TOKEN is required" if access_token.empty?
      raise Error, "HARVEST_ACCOUNT_ID is required" if account_id.empty?

      new(access_token:, account_id:)
    end

    def initialize(access_token:, account_id:, base_url: API_URL, executor: nil)
      @access_token = access_token
      @account_id = account_id
      @base_url = base_url
      @executor = executor || method(:perform_request)
    end

    def request(method, path, params: {}, body: nil)
      uri = URI.join(@base_url, path)
      uri.query = URI.encode_www_form(params) unless params.empty?
      request = request_class(method).new(uri)
      request["Content-Type"] = "application/json" if body
      request.body = JSON.generate(body) if body
      request["Authorization"] = "Bearer #{@access_token}"
      request["Harvest-Account-Id"] = @account_id
      request["User-Agent"] = USER_AGENT

      response = @executor.call(request)
      return JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)

      raise Error.new(response.code, error_message(response.body))
    rescue JSON::ParserError
      raise Error, "Harvest API returned invalid JSON"
    end

    def active_task_assignments
      request(:get, "/v2/task_assignments", params: { is_active: true, per_page: 2000 }).fetch("task_assignments")
    end

    def active_personal_task_assignments
      request(:get, "/v2/users/me/project_assignments", params: { per_page: 2000 })
        .fetch("project_assignments")
        .flat_map do |project_assignment|
          project_assignment.fetch("task_assignments", []).filter_map do |task_assignment|
            task_assignment.merge("project" => project_assignment.fetch("project")) if task_assignment["is_active"]
          end
        end
    end

    def create_time_entry(project_id:, task_id:, spent_date:, hours:, notes: nil)
      body = { project_id:, task_id:, spent_date: spent_date.iso8601, hours: }
      body[:notes] = notes unless notes.nil? || notes.empty?
      request(:post, "/v2/time_entries", body:)
    end

    private

    def request_class(method)
      {
        get: Net::HTTP::Get,
        post: Net::HTTP::Post,
        patch: Net::HTTP::Patch,
        delete: Net::HTTP::Delete
      }.fetch(method.to_sym)
    rescue KeyError
      raise Error, "unsupported HTTP method: #{method}"
    end

    def error_message(body)
      JSON.parse(body).fetch("message", body)
    rescue JSON::ParserError
      body
    end

    def perform_request(request)
      Net::HTTP.start(
        request.uri.host,
        request.uri.port,
        use_ssl: request.uri.scheme == "https"
      ) { |http| http.request(request) }
    end
  end
end
