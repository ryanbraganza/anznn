class BatchSummaryReportGenerator

  attr_accessor :batch_file

  def initialize(batch_file)
    self.batch_file = batch_file
  end

  def generate_report
    file_path = File.join(APP_CONFIG['summary_reports_path'], "#{batch_file.id}-summary.pdf")
    bf = self.batch_file
    Prawn::Document.generate file_path do
      font_size(24)
      text "Validation Report: Summary", :align => :center

      font_size(10)

      move_down 20

      text "Survey: #{bf.survey.name}"
      text "File name: #{bf.file_file_name}"
      text "Date submitted: #{bf.created_at}"
      text "Submitted by: #{bf.user.full_name}"
      text "Status: #{bf.status} (#{bf.message})"

      move_down 10
      text "Number of records: #{bf.record_count}"

      move_down 10
      unless bf.responses.nil?
        answers = bf.responses.collect { |r| r.answers }.flatten
        organiser = QuestionProblemOrganiser.new
        answers.each do |answer|
          organiser.add_problems(answer.question.code, answer.response.baby_code, answer.fatal_warnings, answer.warnings)
        end

        problems_table = organiser.organised_by_question_and_message
        if problems_table.size > 1
          table(problems_table, :header => true, :row_colors => ["FFFFFF", "F0F0F0"]) do
            row(0).font_style = :bold
          end
        end
      end
    end
    file_path
  end
end