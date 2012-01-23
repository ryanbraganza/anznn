class CreateQuestionOptions < ActiveRecord::Migration
  def change
    create_table :question_options do |t|
      t.references :question
      t.string :option_value
      t.string :label
      t.string :hint_text
      t.integer :option_order

      t.timestamps
    end
    add_index :question_options, :question_id
  end
end
