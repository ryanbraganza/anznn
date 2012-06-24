namespace :batch_file do
  desc "Clear failed batch uploads that are older than 30 days"
  task :clear_old => :environment do
    BatchFileCleaner.new.delete_old_files
  end
end

