class AddStringLengthRulesToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :string_min, :integer
    add_column :questions, :string_max, :integer
  end
end
