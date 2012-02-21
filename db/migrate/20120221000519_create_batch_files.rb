class CreateBatchFiles < ActiveRecord::Migration
  def change
    create_table :batch_files do |t|
      t.references :survey
      t.references :user

      t.timestamps
    end
    add_index :batch_files, :survey_id
  end
end
