class AddOrderToQuestionsAndSections < ActiveRecord::Migration
  def change
    add_column :questions, :order, :integer
    add_column :sections, :order, :integer
  end
end
