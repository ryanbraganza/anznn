class AddBatchFileIdToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :batch_file_id, :integer
  end
end
