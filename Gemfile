# frozen_string_literal: true

source 'https://rubygems.org'

# This should correspond to the current value of:
# https://github.com/salsify/cookiecutter-salsify-gem/blob/d0e36dcf7f9ed8b2488de22750742569b0298541/%7B%7Bcookiecutter.repo_name%7D%7D/.github/workflows/release.yml#L22
ruby '2.6.5'

group :development, :test do
  gem 'salsify_rubocop'
end

group :test do
  gem 'rspec'
  gem 'rspec_junit_formatter'
end
