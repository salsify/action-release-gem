# frozen_string_literal: true

require 'fileutils'
require 'tmpdir'

describe "release.rb" do
  let!(:action_path) { Dir.pwd }

  def run_release(env = {})
    env.each do |key, value|
      ENV[key] = value
    end

    load "#{action_path}/release.rb"
  rescue SystemExit # avoid exiting rspec entirely
    nil
  end

  context "with no version change" do
    it "skips the release" do
      with_test_env do
        in_test_gem do
          expect { run_release }.to output(<<~TXT).to_stdout
            Loaded current gemspec with version 0.1.0.test.1.
            Reloading 'test_gem'...
            Loaded previous gemspec with versin 0.1.0.test.1.
            ::set-output name=version::0.1.0.test.1
            ::set-output name=conclusion::skipped
          TXT
        end
      end
    end
  end

  context "with a version change" do
    it "releases the gem" do
      with_test_env do
        in_test_gem do
          File.write('lib/test_gem/version.rb', <<~RUBY)
            module TestGem
              VERSION = '0.1.0.test.2'
            end
          RUBY
          File.write('CHANGELOG.md', <<~RUBY)
            # Changelog

            ## 0.1.0.test.2 - 2000-01-02
            - Test change

            ## 0.1.0.test.1 - 2000-01-01
            - Initial commit
          RUBY

          `git add . && git commit -m 'bump the version'`
          git_sha = `git rev-parse --short HEAD`.chomp

          stub_request(:post, 'https://api.github.com/repos/test_gem/releases').with(
            headers: {
              'Authorization' => 'token github_token'
            },
            body: {
              tag_name: 'v0.1.0.test.2',
              name: 'v0.1.0.test.2',
              body: "- Test change\n",
              target_commitish: git_sha
            }.to_json
          ).to_return(
            body: {
              id: 1
            }.to_json
          )

          expect do
            run_release(
              'RUBYGEMS_API_KEY' => 'rubYgems_key',
              'GITHUB_SHA' => git_sha,
              'GITHUB_REPOSITORY' => 'test_gem',
              'GITHUB_TOKEN' => 'github_token'
            )
          end.to output(<<~TXT).to_stdout
            Loaded current gemspec with version 0.1.0.test.2.
            Reloading 'test_gem'...
            Loaded previous gemspec with versin 0.1.0.test.1.
            ::set-output name=version::0.1.0.test.2
            Using rubygems.org authentication.
            ::set-output name=conclusion::success
            ::set-output name=release-id::1
          TXT
          expect(File.read('release_status.txt')).to eq('RELEASED')
        end
      end
    end
  end

  def with_test_env
    Bundler.with_unbundled_env do
      ENV['ACTION_ENV'] = 'test'
      yield
    end
  end

  def in_test_gem
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        sh('git init')
        sh('git config user.email "tester@test.com"')
        sh('git config user.name "Tester"')

        FileUtils.mkdir_p("#{dir}/lib/test_gem")
        File.write('test_gem.gemspec', <<~RUBY)
          require_relative './lib/test_gem/version'
          Gem::Specification.new do |s|
            s.name = 'test_gem'
            s.version = TestGem::VERSION
            s.summary = 'a test'
            s.authors = ['Hammy']

            s.add_development_dependency 'rake'
          end
        RUBY
        File.write('Gemfile', <<~RUBY)
          source 'https://rubygems.org'
          gemspec
        RUBY
        File.write('lib/test_gem/version.rb', <<~RUBY)
          module TestGem
            VERSION = '0.1.0.test.1'
          end
        RUBY
        File.write('Rakefile', <<~RUBY)
          task :release do
            File.write('release_status.txt', 'RELEASED')
          end
        RUBY

        sh('git add . && git commit -m "Initial commit"')

        yield
      end
    end
  end

  def sh(command)
    system(command, exception: true)
  end
end
