class AddExtraInfoToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :code, :string
    add_column :questions, :description, :text
    add_column :questions, :guide_for_use, :text
  end
end
