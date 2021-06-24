class VersionDiff
  class << self
    def load!
      gemspec = load_gemspec
      puts "Loaded current gemspec with version #{gemspec.version}."

      previous_gemspec = git_checkout('HEAD~1') do
        reload_gem(gemspec.name)
        load_gemspec.tap do |prev|
          puts "Loaded previous gemspec with versin #{prev.version}."
        end
      end

      new(gemspec, previous_gemspec)
    end

    private

    def load_gemspec
      gemspecs = Dir.glob('*.gemspec')
      exit_with_error('Zero or multiple gemspecs found. Must be exactly 1') if gemspecs.count != 1

      Gem::Specification.reset
      Gem::Specification.load(gemspecs.first)
    end

    def reload_gem(name)
      puts "Reloading '#{name}'..."

      $LOADED_FEATURES.grep(/#{Regexp.escape(name)}/) do |path|
        load(path)
      rescue LoadError
        warn "LoadError while reloading #{path}, continuing..."
      end
    end
  end

  def initialize(gemspec, previous_gemspec)
    @gemspec = gemspec
    @previous_gemspec = previous_gemspec
  end

  def current_version
    @gemspec.version
  end

  def previous_version
    @previous_gemspec.version
  end

  def changes
    extract_changes(current_version) || 'No changes noted.'
  end

  def new_version?
    previous_version != current_version
  end

  def private_gem?
    @gemspec.metadata['allowed_push_host'] == 'https://gems.salsify.com'
  end

  private

  def extract_changes(version)
    unless File.exist?('CHANGELOG.md')
      log_warning('No CHANGELOG.md found')
      return
    end

    changelog = File.read('CHANGELOG.md')
    changes_regex = /^## [v|\[]?#{Regexp.escape(version.to_s)}.*?\R(.*?)^## /m
    changelog.match(changes_regex)&.[](1)&.chomp
  end
end
