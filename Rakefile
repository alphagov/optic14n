$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  puts "Running in production mode"
end

require 'bundler/gem_tasks'
require 'optic14n'
Dir.glob('lib/tasks/*.rake').each { |r| import r }

task default: :spec
task test: :spec
