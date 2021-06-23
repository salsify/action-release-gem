require 'fileutils'
require 'rest-client'
require 'yaml'

def with_gem_auth(is_private, &block)
  if is_private
    puts "Using gems.salsify.com authentication."
    with_gems_salsify_auth(&block)
  else
    puts "Using rubygems.org authentication."
    with_ruby_gems_auth(&block)
  end
end

def with_ruby_gems_auth
  with_credentials_file do |creds_file|
    api_key = ENV['RUBYGEMS_API_KEY'] or exit_with_error("RUBYGEMS_API_KEY not set!")
    File.write(creds_file, { rubygems_api_key: api_key }.to_yaml)

    yield
  end
end

def with_gems_salsify_auth
  with_credentials_file do |creds_file|
    auth = ENV['ARTIFACTORY_AUTH_STRING'] or exit_with_error("ARTIFACTORY_AUTH_STRING not set!")
    api_key = RestClient.get("https://#{auth}@gems.salsify.com/api/v1/api_key").body
    File.write(creds_file, { gems_salsify_com: api_key }.to_yaml)

    system('bundle config gems.salsify.com #{auth}', exception: true)

    yield
  ensure
    system('bundle config gems.salsify.com')
  end
end

def with_credentials_file
  gem_dir = File.join(Dir.home, '.gem')
  creds_file = File.join(gem_dir, 'credentials')

  FileUtils.mkdir_p(gem_dir)
  FileUtils.touch(creds_file)
  FileUtils.chmod(0600, creds_file)

  yield creds_file
ensure
  FileUtils.remove_dir(gem_dir, true)
end

def release_gem
  system('bundle install --jobs=4 --retry=3', exception: true)

  as_git_user(name: 'github-actions', email: 'github-actions@user.noreply.github.com') do
    system('bundle exec rake release', exception: true)
  end
end
