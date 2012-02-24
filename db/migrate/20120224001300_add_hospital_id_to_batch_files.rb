class AddHospitalIdToBatchFiles < ActiveRecord::Migration
  def change
    add_column :batch_files, :hospital_id, :integer
  end
end
