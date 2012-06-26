class AddCommentsToCrossQuestionValidations < ActiveRecord::Migration
  def up
    add_column :cross_question_validations, :comments, :text
  end
  def down
    add_column :cross_question_validations, :comments, :text
  end
end
