# frozen_string_literal: true

module HarvestApiV2
  class Error < StandardError
    attr_reader :status

    def initialize(status = nil, message = nil)
      @status = message ? status : nil
      super(message || status)
    end
  end
end
