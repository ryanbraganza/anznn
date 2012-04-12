class RenameOrderColumn < ActiveRecord::Migration
  def change
    rename_column :questions, :order, :question_order
    rename_column :sections, :order, :section_order
  end
end
