class CreateSupplementaryFiles < ActiveRecord::Migration
  def change
    create_table :supplementary_files do |t|
      t.string :multi_name
      t.references :batch_file
      t.has_attached_file :file
      t.timestamps
    end
    add_index :supplementary_files, :batch_file_id
  end
end
