class BatchSummaryReportGenerator

  attr_accessor :batch_file

  def initialize(batch_file)
    self.batch_file = batch_file
  end

  def generate_report
    file_path = File.join(APP_CONFIG['summary_reports_path'], "#{batch_file.id}-summary.pdf")
    Prawn::Document.generate file_path do
      text "Validation Report: Summary"
    end
    file_path
  end
end