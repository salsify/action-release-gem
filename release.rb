require_relative './action_utils'
require_relative './git_utils'

if ENV['VERSION_CHANGED'] != 'true'
  output('conclusion' => 'skipped')
  exit(0)
end

def release_gem
  as_git_user(name: 'github-actions', email: 'github-actions@user.noreply.github.com') do
    system('bundle exec rake release')
  end
end

system('bundle install --jobs=4 --retry=3')

if release_gem
  output('conclusion' => 'success')
else
  exit_with_error('Release failed')
end
