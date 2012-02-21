class AddHospitalIdToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :hospital_id, :integer
  end
end
