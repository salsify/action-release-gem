def git(command, *args)
  quoted_args = args.map { |arg| "\"#{arg}\"" }
  `git #{command} #{quoted_args.join(' ')}`.chomp
end

def git_checkout(ref)
  old_ref = git('rev-parse --abbrev-ref HEAD')
  old_ref = git('rev-parse HEAD') if old_ref == 'HEAD'
  git('checkout', ref)
  yield
ensure
  git('checkout', old_ref)
end

def as_git_user(name:, email:)
  old_name = git('config user.name')
  old_email = git('config user.email')
  git('config user.name', name)
  git('config user.email', email)
  yield
ensure
  git('config user.name', old_name)
  git('config user.email', old_email)
end
