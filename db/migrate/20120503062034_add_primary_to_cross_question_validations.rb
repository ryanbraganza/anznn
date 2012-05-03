class AddPrimaryToCrossQuestionValidations < ActiveRecord::Migration
  def change
    add_column :cross_question_validations, :primary, :boolean
  end
end
