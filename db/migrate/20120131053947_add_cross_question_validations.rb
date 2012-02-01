class AddCrossQuestionValidations < ActiveRecord::Migration
  def change
    create_table :cross_question_validations do |t|
      t.integer :question_id
      t.integer :related_question_id
      t.string :rule
      t.string :error_message
    end
  end
end
