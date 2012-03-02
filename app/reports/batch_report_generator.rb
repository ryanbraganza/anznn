class BatchReportGenerator

  attr_accessor :batch_file

  def initialize(batch_file)
    self.batch_file = batch_file
  end

  def generate_reports
    organiser = batch_file.organised_problems

    summary_file_path = File.join(APP_CONFIG['batch_reports_path'], "#{batch_file.id}-summary.pdf")
    BatchSummaryReportGenerator.generate_report(batch_file, organiser, summary_file_path)
    batch_file.summary_report_path = summary_file_path

    unless batch_file.success?
      detail_file_path = File.join(APP_CONFIG['batch_reports_path'], "#{batch_file.id}-details.csv")
      BatchDetailReportGenerator.generate_report(organiser, detail_file_path)
      batch_file.detail_report_path = detail_file_path
    end
  end

end