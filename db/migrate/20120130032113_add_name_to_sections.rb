class AddNameToSections < ActiveRecord::Migration
  def change
    add_column :sections, :name, :string
  end
end
