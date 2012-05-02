require File.dirname(__FILE__) + '/sample_data_populator.rb'
begin
  namespace :db do
    desc "Populate the database with some sample data for testing"
    task :populate => :environment do
      populate_data
    end

    desc "Populate the database with data suitable for performance testing"
    task :big_populate => :environment do
      big_populate
    end
  end
rescue LoadError
  puts "It looks like some Gems are missing: please run bundle install"
end
