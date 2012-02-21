class AddFileToBatchFiles < ActiveRecord::Migration
  def up
    change_table :batch_files do |t|
      t.has_attached_file :file
    end

  end

  def down
    drop_attached_file :batch_files, :file
  end
end
