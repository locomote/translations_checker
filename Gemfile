source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in translations_checker.gemspec
gemspec

gem "activesupport",   ENV["CI_RAILS_VERSION"]           if ENV["CI_RAILS_VERSION"]
gem "concurrent-ruby", ENV["CI_CONCURRENT_RUBY_VERSION"] if ENV["CI_CONCURRENT_RUBY_VERSION"]
