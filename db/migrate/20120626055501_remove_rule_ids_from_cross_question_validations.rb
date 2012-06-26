class RemoveRuleIdsFromCrossQuestionValidations < ActiveRecord::Migration
  def up
    remove_column :cross_question_validations, :related_rule_ids
    remove_column :cross_question_validations, :primary
  end
  def down
    add_column :cross_question_validations, :related_rule_ids, :string
    add_column :cross_question_validations, :primary, :boolean
  end
end
