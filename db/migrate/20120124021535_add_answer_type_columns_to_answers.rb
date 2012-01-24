class AddAnswerTypeColumnsToAnswers < ActiveRecord::Migration
  def change
    change_table :answers do |t|
      t.date :date_answer
      t.time :time_answer
      t.float :decimal_answer
      t.integer :integer_answer
    end
    say "Columns created for all currently configured answer types EXCEPT 'Choice'"
  end
end
