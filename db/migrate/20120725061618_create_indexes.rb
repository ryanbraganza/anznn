class CreateIndexes < ActiveRecord::Migration
  def change
    add_index :answers, :response_id
  end
end
