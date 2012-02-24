class AddMessageToBatchFiles < ActiveRecord::Migration
  def change
    add_column :batch_files, :message, :string
  end
end
