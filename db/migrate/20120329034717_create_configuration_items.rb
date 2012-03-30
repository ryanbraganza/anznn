class CreateConfigurationItems < ActiveRecord::Migration
  def change
    create_table :configuration_items do |t|
      t.string :name
      t.string :configuration_value

      t.timestamps
    end
  end
end
