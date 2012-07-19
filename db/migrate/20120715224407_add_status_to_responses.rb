class AddStatusToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :validation_status, :string
  end
end
