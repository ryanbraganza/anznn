class AddFieldsToCrossQuestionValidations < ActiveRecord::Migration
  def change
    add_column :cross_question_validations, :operator, :string
    add_column :cross_question_validations, :constant, :decimal
  end
end
