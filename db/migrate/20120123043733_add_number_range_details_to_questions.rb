class AddNumberRangeDetailsToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :number_min, :integer
    add_column :questions, :number_max, :integer
    add_column :questions, :number_unknown, :integer
  end
end
