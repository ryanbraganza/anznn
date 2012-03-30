class AddYearOfRegistrationToBatchFiles < ActiveRecord::Migration
  def change
    add_column :batch_files, :year_of_registration, :integer
  end
end
