class BatchFileCleaner
  def delete_old_files
    BatchFile.failed.older_than(30.days.ago).each do |batch_file|
      batch_file.delete
    end
  end
end
