class DropDataDomainFromQuestions < ActiveRecord::Migration
  def change
    remove_column :questions, :data_domain
  end
end
