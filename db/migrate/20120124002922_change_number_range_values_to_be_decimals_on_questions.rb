class ChangeNumberRangeValuesToBeDecimalsOnQuestions < ActiveRecord::Migration
  def change
    change_column :questions, :number_min, :decimal
    change_column :questions, :number_max, :decimal
  end
end
