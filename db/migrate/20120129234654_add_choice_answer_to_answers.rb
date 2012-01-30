class AddChoiceAnswerToAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :choice_answer, :string
  end
end
