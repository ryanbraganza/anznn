class AddCommentsToCrossQuestionValidations < ActiveRecord::Migration
  def change
    add_column :cross_question_validations, :comments, :text
  end
end
