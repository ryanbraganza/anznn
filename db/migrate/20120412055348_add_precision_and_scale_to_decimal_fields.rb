class AddPrecisionAndScaleToDecimalFields < ActiveRecord::Migration
  def change
    change_column :answers, :decimal_answer, :decimal, precision: 65, scale: 15
    change_column :cross_question_validations, :constant, :decimal, precision: 65, scale: 15
    change_column :cross_question_validations, :conditional_constant, :decimal, precision: 65, scale: 15
    change_column :questions, :number_min, :decimal, precision: 65, scale: 15
    change_column :questions, :number_max, :decimal, precision: 65, scale: 15
  end
end
