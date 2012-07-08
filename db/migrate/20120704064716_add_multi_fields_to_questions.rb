class AddMultiFieldsToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :multiple, :boolean, default: false
    add_column :questions, :multi_name, :string
    add_column :questions, :group_number, :integer
    add_column :questions, :order_within_group, :integer
  end
end
