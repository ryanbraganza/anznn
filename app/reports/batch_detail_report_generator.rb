class BatchDetailReportGenerator

  attr_accessor :batch_file

  def initialize(batch_file)
    self.batch_file = batch_file
  end

  def generate_report
    file_path = File.join(APP_CONFIG['batch_reports_path'], "#{batch_file.id}-details.csv")

    unless batch_file.responses.nil?
      organiser = QuestionProblemDetailOrganiser.new

      batch_file.responses.each do |r|
        r.answers.each do |answer|
          organiser.add_problems(answer.question.code, r.baby_code, answer.fatal_warnings, answer.warnings, answer.answer_value)
        end
        r.missing_mandatory_questions.each do |question|
          organiser.add_problems(question.code, r.baby_code, ["This question is mandatory"], [], "")
        end
      end
      problems = organiser.sorted_problems

      CSV.open(file_path, "wb") do |csv|
        csv.add_row ['BabyCode', 'Column Name', 'Type', 'Value', 'Message']
        problems.each do |entry|
          csv.add_row entry
        end
      end
    end

    file_path
  end
end