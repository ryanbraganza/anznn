# Eventually, there is the plan to import new surveys from file - PERI-29
#  "As the ANZNN owner I want to manage the questionnaire so I can make changes without needing a developer"
# This module can be extended to handle that functionality, but for the moment it is just used to populate
# sample and test surveys

module CsvSurveyOperations
  def read_hashes_from_csv(file_name)

    begin
      line = 1
      CSV.foreach(file_name) do |row|
        line+=1
        # use row here...
      end
    rescue
      puts "Failed on row #{line} of #{file_name}"
      raise
    end

    csv_data = CSV.read(file_name)
    headers = csv_data.shift.map { |i| i.to_s }
    string_data = csv_data.map { |row| row.map { |cell| cell.to_s } }
    string_data.map { |row| Hash[*headers.zip(row).flatten] }
  end

  def import_questions(survey, questions)
    order = 0
    questions.each do |hash|
      section_name = hash.delete('section')
      section = survey.sections.find_or_initialize_by_name(section_name)
      if section.new_record?
        section.section_order = order
        section.save!

        order += 1
      end
      Question.create!(hash.merge(section_id: section.id))
    end
  end

  def import_question_options(survey, question_options)
    question_options.each do |qo|
      code = qo.delete("code")
      question = survey.questions.find_by_code!(code)
      question.question_options.create!(qo)
    end
  end

  def import_cross_question_validations(survey, cqv_hashes)
    cqv_hashes.each do |cqv_hash|
      question_code = cqv_hash.delete 'question_code'
      related_question_code = cqv_hash.delete 'related_question_code'
      set_string = cqv_hash.delete 'set'
      conditional_set_string = cqv_hash.delete 'conditional_set'

      set = set_string.blank? ? nil : eval(set_string)
      conditional_set = conditional_set_string.blank? ? nil : eval(conditional_set_string)


      question = survey.questions.find_by_code!(question_code)
      related_question = survey.questions.find_by_code!(related_question_code)

      attrs = cqv_hash.merge(question: question, related_question: related_question, set: set, conditional_set: conditional_set)

      CrossQuestionValidation.create!(attrs)
    end
  end

  def create_survey(name, question_file, options_file=nil, cross_question_validations_file=nil)
    ActiveRecord::Base.transaction do

      survey = Survey.create!(name: name)

      questions = read_hashes_from_csv(question_file)
      import_questions(survey, questions)
      if options_file
        question_options = read_hashes_from_csv(options_file)
        import_question_options(survey, question_options)
      end

      if cross_question_validations_file
        cqv_hashes = read_hashes_from_csv(cross_question_validations_file)
        import_cross_question_validations(survey, cqv_hashes)
      end
      survey
    end
  end
end
