class AddYearOfRegToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :year_of_registration, :integer
  end
end
