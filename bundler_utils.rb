def release_gem
  system('bundle install --jobs=4 --retry=3')

  as_git_user(name: 'github-actions', email: 'github-actions@user.noreply.github.com') do
    system('bundle exec rake release')
  end
end
