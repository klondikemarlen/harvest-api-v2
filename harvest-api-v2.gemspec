# frozen_string_literal: true

require_relative "lib/harvest_api_v2/version"

Gem::Specification.new do |spec|
  spec.name = "harvest-api-v2"
  spec.version = HarvestApiV2::VERSION
  spec.authors = ["Marlen Brunner"]
  spec.email = ["klondikemarlen@gmail.com"]
  spec.summary = "Small Ruby client for Harvest API V2."
  spec.homepage = "https://github.com/klondikemarlen/harvest-api-v2"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir["lib/**/*.rb", "README.md", "LICENSE.txt"]
  spec.require_paths = ["lib"]
end
