class AddFieldsToCrossQuestionValidation < ActiveRecord::Migration
  def change
    add_column :cross_question_validations, :set_operator, :string
    add_column :cross_question_validations, :set, :string
    add_column :cross_question_validations, :conditional_operator, :string
    add_column :cross_question_validations, :conditional_constant, :decimal
    add_column :cross_question_validations, :conditional_set_operator, :string
    add_column :cross_question_validations, :conditional_set, :string
  end
end
