class AddDetailReportPathToBatchFiles < ActiveRecord::Migration
  def change
    add_column :batch_files, :detail_report_path, :string
  end
end
