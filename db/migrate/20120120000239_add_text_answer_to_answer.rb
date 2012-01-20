class AddTextAnswerToAnswer < ActiveRecord::Migration
  def change
    add_column :answers, :text_answer, :text
  end
end
