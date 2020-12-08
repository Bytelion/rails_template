# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation'
require 'rspec_api_documentation/dsl'

RspecApiDocumentation.configure do |config|
  config.format = %i[api_blueprint html]
  config.request_body_formatter = :json
  config.request_headers_to_include = %w[Content-Type Accept]
  config.response_headers_to_include = %w[Content-Type]
  config.api_name = 'Rails API Template'
  config.curl_host = 'https://www.examplehost.com'
  config.api_explanation = 'This API Documentation describes the collections that are contained in the backend project for the Rails API Template.'
end

def json_collection(collection)
  collection.to_json
end

def json_item(item)
  item.to_json
end

def json
  JSON.parse(response_body)
end

def apple_test_token
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoiY29tLnNhcnVudy5zaXdhIiwiZXhwIjoxNTc3OTQzNjEzLCJpYXQiOjE1Nzc5NDMwMTMsInN1YiI6Inh4eC55eXkuenp6Iiwibm9uY2UiOiJub3VuY2UiLCJjX2hhc2giOiJ4eHh4IiwiZW1haWwiOiJ4eHh4QHByaXZhdGVyZWxheS5hcHBsZWlkLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjoidHJ1ZSIsImlzX3ByaXZhdGVfZW1haWwiOiJ0cnVlIiwiYXV0aF90aW1lIjoxNTc3OTQzMDEzfQ.SpkxAE8vjyFinHV5I7ETCVZDqAURrR6gGDxYQ1_jKGI'
end
