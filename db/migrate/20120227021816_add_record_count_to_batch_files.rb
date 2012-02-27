class AddRecordCountToBatchFiles < ActiveRecord::Migration
  def change
    add_column :batch_files, :record_count, :integer
  end
end
