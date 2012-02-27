class AddSubmittedStatusToResponse < ActiveRecord::Migration
  def change
    add_column :responses, :submitted_status, :string
  end
end
