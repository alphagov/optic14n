$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'optic14n'
Dir.glob('lib/tasks/*.rake').each { |r| import r }


require 'gem_publisher'
desc 'Publish gem to Gemfury'
task :publish_gem do
  gem = GemPublisher.publish_if_updated('optic14n.gemspec', :gemfury, :as => 'govuk')
  puts "Published #{gem}" if gem
end

RSpec::Core::RakeTask.new(:spec)

task default: :spec
task test: :spec
