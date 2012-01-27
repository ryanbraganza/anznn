# Eventually, there is the plan to import new surveys from file - PERI-29
#  "As the ANZNN owner I want to manage the questionnaire so I can make changes without needing a developer"
# This module can be extended to handle that functionality, but for the moment it is just used to populate
# sample and test surveys

module CsvSurveyOperations
  def read_hashes_from_csv(file_name)
    csv_data = CSV.read(file_name)
    headers = csv_data.shift.map { |i| i.to_s }
    string_data = csv_data.map { |row| row.map { |cell| cell.to_s } }
    string_data.map { |row| Hash[*headers.zip(row).flatten] }
  end

  def import_questions(survey, questions)
    questions.each do |hash|
      section_order = hash.delete('section')
      section = survey.sections.find_or_create_by_order(section_order)
      Question.create!(hash.merge(section_id: section.id))
    end
  end

  def import_question_options(survey, question_options)
    question_options.each do |qo|
      code = qo.delete("code")
      question = survey.questions.find_by_code(code)
      question.question_options.create!(qo)
    end
  end
end