require_relative './action_utils'
require_relative './git_utils'

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

def extract_and_write_changes(version)
  changes = extract_changes(version) || 'No changes noted.'
  "CHANGES-#{version}.md".tap do |path|
    File.write(path, changes)
  end
end

current_gemspec = load_gemspec
current_version = current_gemspec.version
previous_version = git_checkout('HEAD~1') do
  reload_gem(current_gemspec.name)
  load_gemspec.version
end

output(
  'current-version' =>  current_version,
  'previous-version' => previous_version,
  'version-changed' => current_version != previous_version,
  'changes' => extract_and_write_changes(current_version)
)
