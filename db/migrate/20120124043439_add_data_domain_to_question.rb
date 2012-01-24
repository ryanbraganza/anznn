class AddDataDomainToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :data_domain, :text
  end
end
