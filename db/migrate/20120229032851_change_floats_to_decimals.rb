class ChangeFloatsToDecimals < ActiveRecord::Migration
  def change
    change_column :answers, :decimal_answer, :decimal
  end

end
