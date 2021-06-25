# frozen_string_literal: true

require_relative './action_utils'
require_relative './git_utils'

class VersionDiff
  class << self
    def load!
      current_gemspec = load_gemspec
      current_version = current_gemspec.version
      previous_version = git_checkout('HEAD~1') do
        reload_gem(current_gemspec.name)
        load_gemspec.version
      end

      new(current_version, previous_version, extract_changes || 'No changes noted.')
    end

    private

    def load_gemspec
      gemspecs = Dir.glob('*.gemspec')
      exit_with_error('Zero or multiple gemspecs found. Must be exactly 1') if gemspecs.count != 1

      Gem::Specification.reset
      Gem::Specification.load(gemspecs.first)
    end

    def reload_gem(name)
      $LOADED_FEATURES.grep(/#{Regexp.escape(name)}/) do |path|
        load(path)
      rescue LoadError
        # Ignore
      end
    end

    def extract_changes(version)
      unless File.exist?('CHANGELOG.md')
        log_warning('No CHANGELOG.md found')
        return
      end

      changelog = File.read('CHANGELOG.md')
      changes_regex = /^## [v|\[]?#{Regexp.escape(version.to_s)}.*?\R(.*?)^##/m
      changelog.match(changes_regex)&.[](1)&.chomp
    end
  end

  def initialize(current_version, previous_version, changes)
    @current_version = current_version
    @previous_version = previous_version
    @changes = changes
  end

  attr_reader :current_version, :previous_version, :changes

  def new_version?
    previous_version != current_version
  end
end
