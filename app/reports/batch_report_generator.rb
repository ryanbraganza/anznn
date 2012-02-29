class BatchReportGenerator

  attr_accessor :batch_file

  def initialize(batch_file)
    self.batch_file = batch_file
  end

  def generate_reports
    organiser = QuestionProblemsOrganiser.new

    # get all the problems from all the responses organised for reporting
    batch_file.responses.each do |r|
      r.answers.each do |answer|
        organiser.add_problems(answer.question.code, r.baby_code, answer.fatal_warnings, answer.warnings, answer.answer_value)
      end
      r.missing_mandatory_questions.each do |question|
        organiser.add_problems(question.code, r.baby_code, ["This question is mandatory"], [], "")
      end
    end

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