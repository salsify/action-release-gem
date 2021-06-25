# frozen_string_literal: true

require 'webmock/rspec'

RSpec.configure do |config|
  config.before(:suite) do
    WebMock.disable_net_connect!
  end
end
