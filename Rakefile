$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require "rspec/core/rake_task"
require "rubocop/rake_task"
require "bundler/gem_tasks"
require "optic14n"
Dir.glob("lib/tasks/*.rake").each { |r| import r }

RuboCop::RakeTask.new
RSpec::Core::RakeTask.new(:spec)

task default: %i[rubocop spec]
