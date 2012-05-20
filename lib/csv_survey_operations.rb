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
    questions.each do |hash|
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
    failing_items = []
    make_cqvs(survey, cqv_hashes, failing_items)
    puts "FAILING ITEMS #{failing_items.sort}"
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

  def make_cqvs(survey, hashes, failing_items)
    label_to_cqv_id = {}

    # store the labelled (secondary) rules first
    hashes.each do |hash|
      rule_label = hash['rule_label']
      make_cqv(survey, label_to_cqv_id, hash.merge(primary: false), failing_items) if rule_label.present?
    end

    #now store any rules which reference labelled rules
    hashes.each do |hash|
      rule_label = hash['rule_label']
      make_cqv(survey, label_to_cqv_id, hash.merge(primary: true), failing_items) unless rule_label.present?
    end
  end

  def make_cqv(survey, label_to_cqv_id, hash, failing_items)

    orig = hash.dup
    begin
      related_question_question = hash.delete 'related_question_code'
      related_rule_labels = hash.delete 'rule_label_list'
      question_list = hash.delete 'related_question_list'
      question_question = hash.delete 'question_code'
      raise orig.inspect unless question_question
      label = hash.delete 'rule_label'
      hash.delete 'itemnum'

      hash[:related_question] = related_question_question.blank? ? nil : survey.questions.find_by_code!(related_question_question)

      if question_list
        hash[:related_question_ids] = question_list.split(", ").map { |qn_code| survey.questions.find_by_code!(qn_code).id }
      end

      if related_rule_labels
        hash[:related_rule_ids] = related_rule_labels.split(', ').map do |related_label|
          if label_to_cqv_id[related_label].blank?
            raise ActiveRecord::RecordNotSaved, "Couldn't find a Cross Question Validation Rule with label '#{related_label}'"
          end
          label_to_cqv_id[related_label]
        end
      end

      hash[:question] = survey.questions.find_by_code! question_question

      validation = CrossQuestionValidation.create!(hash)
      label_to_cqv_id[label] = validation.id
    rescue
      puts "Failed to create cqv #{orig}, continuing anyway"
      failing_items << orig['itemnum']
      puts $!
      #TODO: temporary measure while we're building the rules: add back later
      #raise
    end

  end
end
