unless ARGV.any? { |a| a =~ /^gems/ } # Don't load anything when running the gems:* tasks

  vendored_cucumber_bin = Dir["#{Rails.root}/vendor/{gems,plugins}/cucumber*/bin/cucumber"].first
  $LOAD_PATH.unshift(File.dirname(vendored_cucumber_bin) + '/../lib') unless vendored_cucumber_bin.nil?

  begin
    require 'cucumber/rake/task'

    namespace :cucumber do
      Cucumber::Rake::Task.new({:doc => 'db:test:prepare'}, 'Run all features and generate html output') do |t|
        t.binary = vendored_cucumber_bin # If nil, the gem's binary is used.
        t.fork = true # You may get faster startup if you set this to false
        t.profile = 'doc'
      end
    end

  rescue LoadError
    desc 'cucumber rake task not available (cucumber not installed)'
    task :cucumber do
      abort 'Cucumber rake task is not available. Be sure to install cucumber as a gem or plugin'
    end
  end

end

namespace :spec do
  require 'rake'
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:doc) do |t|
    t.rspec_opts = '--format html --out doc/developer/rspec.html'
  end

  task :default  => :spec
end

task :generate_docs => ['cucumber:doc', 'spec:doc']