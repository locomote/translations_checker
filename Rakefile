require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

namespace :quality do
  require "rubocop/rake_task"

  RuboCop::RakeTask.new

  require "reek/rake/task"

  Reek::Rake::Task.new do |task|
    task.source_files = FileList["{lib}/**/*.rb"]
  end
end

desc "Run all code quality checks"
task quality: %w(quality:rubocop quality:reek)
