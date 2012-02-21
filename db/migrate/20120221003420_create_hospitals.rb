class CreateHospitals < ActiveRecord::Migration
  def change
    create_table :hospitals do |t|
      t.string :state
      t.string :name
      t.string :abbrev

      t.timestamps
    end
    change_table :users do |t|
      t.integer :hospital_id
    end
  end
end
