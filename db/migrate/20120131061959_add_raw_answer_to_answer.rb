class AddRawAnswerToAnswer < ActiveRecord::Migration
  def change
    add_column :answers, :raw_answer, :string
  end
end
