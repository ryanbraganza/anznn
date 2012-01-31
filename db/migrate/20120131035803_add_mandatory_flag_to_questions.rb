class AddMandatoryFlagToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :mandatory, :boolean
  end
end
