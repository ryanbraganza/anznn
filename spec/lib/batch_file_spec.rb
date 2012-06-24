require 'spec_helper'

describe BatchFileCleaner do
  it "deletes old failed batch files" do
    batch_file = Factory :batch_file, status: BatchFile::STATUS_FAILED, updated_at: 35.days.ago

    lambda do
      subject.delete_old_files
    end.should change(BatchFile, :count).by(-1)
  end

  it "does not delete old 'non failed' files" do
    batch_file = Factory :batch_file, status: BatchFile::STATUS_SUCCESS, updated_at: 35.days.ago

    lambda do
      subject.delete_old_files
    end.should_not change(BatchFile, :count)
  end

  it "does not delete recent failed files" do
    batch_file = Factory :batch_file, status: BatchFile::STATUS_FAILED, updated_at: 25.days.ago

    lambda do
      subject.delete_old_files
    end.should_not change(BatchFile, :count)
  end
end

