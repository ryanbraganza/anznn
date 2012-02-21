class AddStatusToBatchFiles < ActiveRecord::Migration
  def change
    add_column :batch_files, :status, :string
  end
end
