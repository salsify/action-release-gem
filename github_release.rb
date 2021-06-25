# frozen_string_literal: true

require 'json'
require 'rest-client'

class GitHubRelease
  class << self
    def create!(version_diff)
      response = RestClient.post(url, payload(version_diff), headers)
      new(JSON.parse(response.body))
    rescue RestClient::ExceptionWithResponse => e
      exit_with_error(e.response)
    end

    private

    def payload(version_diff)
      {
        tag_name: "v#{version_diff.current_version}",
        name: "v#{version_diff.current_version}",
        body: version_diff.changes,
        target_commitish: ENV['GITHUB_SHA']
      }.to_json
    end

    def url
      "https://api.github.com/repos/#{ENV['GITHUB_REPOSITORY']}/releases"
    end

    def headers
      {
        'Content-Type' => 'application/json',
        'Authorization' => "token #{ENV['GITHUB_TOKEN']}"
      }
    end
  end

  def initialize(release_data)
    @release_data = release_data
  end

  def id
    @release_data['id']
  end
end
