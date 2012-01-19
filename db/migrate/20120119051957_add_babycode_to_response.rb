class AddBabycodeToResponse < ActiveRecord::Migration
  def change
    change_table :responses do |t|
      t.string :baby_code
      t.timestamps
    end
  end
end
