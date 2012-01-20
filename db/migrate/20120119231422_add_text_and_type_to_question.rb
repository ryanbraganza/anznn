class AddTextAndTypeToQuestion < ActiveRecord::Migration
  def change
    change_table :questions do |t|
      t.string :question
      t.string :question_type
    end
  end
end
