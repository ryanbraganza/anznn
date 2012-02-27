class AddSummaryFilePathToBatchFiles < ActiveRecord::Migration
  def change
    add_column :batch_files, :summary_report_path, :string
  end
end
