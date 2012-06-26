# This module is used to import questionnaire configuration from CSV files

module CsvSurveyOperations
  def read_hashes_from_csv(file_name)

    csv_data = CSV.read(file_name)
    headers = csv_data.shift.map { |i| i.to_s }
    string_data = csv_data.map { |row| row.map { |cell| cell.to_s } }
    string_data.map { |row| Hash[*headers.zip(row).flatten] }
  end

  def import_questions(survey, questions)
    order = 0
    question_codes = []
    questions.each do |hash|
      if hash["code"].present? && question_codes.include?(hash["code"].downcase)
        raise InputError, "Question Code #{hash["code"]} exists more than once"
      end
      question_codes << hash["code"].downcase unless hash["code"].blank?

      section_name = hash.delete('section')
      section = survey.sections.find_or_initialize_by_name(section_name)
      if section.new_record?
        section.section_order = order
        section.save!

        order += 1
      end
      begin
        Question.create!(hash.merge(section_id: section.id))
      rescue
        puts "Failed to create question #{hash}"
        raise
      end
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
    cqv_hashes = cqv_hashes.map do |hash|
      set_string = hash.delete 'set'
      conditional_set_string = hash.delete 'conditional_set'

      set = set_string.blank? ? nil : eval(set_string)
      conditional_set = conditional_set_string.blank? ? nil : eval(conditional_set_string)

      hash.merge(set: set, conditional_set: conditional_set)
    end
    make_cqvs(survey, cqv_hashes)
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

  def make_cqvs(survey, hashes)
    hashes.each do |hash|
      make_cqv(survey, hash)
    end
  end

  def make_cqv(survey, hash)

    orig = hash.dup
    begin
      related_question_question = hash.delete 'related_question_code'
      question_list = hash.delete 'related_question_list'
      question_question = hash.delete 'question_code'
      raise orig.inspect unless question_question
      hash.delete 'itemnum'
      hash.delete 'reviewed by Kali'

      hash[:related_question] = related_question_question.blank? ? nil : survey.questions.find_by_code!(related_question_question)

      if question_list
        hash[:related_question_ids] = question_list.split(", ").map { |qn_code| survey.questions.find_by_code!(qn_code).id }
      end

      hash[:question] = survey.questions.find_by_code! question_question

      CrossQuestionValidation.create!(hash)
    rescue
      puts "Failed to create cqv #{orig}, continuing anyway"
      puts $!
      raise
    end

  end
end
