# frozen_string_literal: true

require_relative './action_utils'
require_relative './bundler_utils'
require_relative './git_utils'
require_relative './github_release'
require_relative './version_diff'

version_diff = VersionDiff.load!
output('version' => version_diff.current_version)
exit_with_output('conclusion' => 'skipped') unless version_diff.new_version?

with_gem_auth(version_diff.private_gem?) do
  release_gem || exit_with_error('Release failed')
end

release = GitHubRelease.create!(version_diff)
output('conclusion' => 'success', 'release-id' => release.id)
