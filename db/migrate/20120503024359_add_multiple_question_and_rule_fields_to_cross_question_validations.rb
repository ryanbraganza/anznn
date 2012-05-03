class AddMultipleQuestionAndRuleFieldsToCrossQuestionValidations < ActiveRecord::Migration
  def change
    add_column :cross_question_validations, :related_question_ids, :string
    add_column :cross_question_validations, :related_rule_ids, :string
  end
end
