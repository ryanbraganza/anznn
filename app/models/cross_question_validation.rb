class CrossQuestionValidation < ActiveRecord::Base

  cattr_accessor(:valid_rules) { [] }
  cattr_accessor(:rules_with_no_related_question) { [] }

  RULES_THAT_APPLY_EVEN_WHEN_RELATED_ANSWER_NIL = %w(present_implies_present const_implies_present set_implies_present blank_unless_present set_gest_wght_implies_present)

  SAFE_OPERATORS = %w(== <= >= < > !=)
  ALLOWED_SET_OPERATORS = %w(included excluded range)

  GEST_CODE = 'Gest'
  WGHT_CODE = 'Wght'

  GEST_LT = 32
  WGHT_LT = 1500

  belongs_to :question
  belongs_to :related_question, class_name: 'Question'

  validates_inclusion_of :rule, in: valid_rules
  validates_inclusion_of :operator, in: SAFE_OPERATORS, allow_blank: true

  validates_presence_of :question_id
  validate :one_of_related_question_or_list_of_questions
  validates_presence_of :rule
  validates_presence_of :error_message

  serialize :related_question_ids, Array
  serialize :set, Array
  serialize :conditional_set, Array


  def one_of_related_question_or_list_of_questions
    return if rules_with_no_related_question.include?(rule)
    unless [related_question_id, related_question_ids].count(&:present?) == 1
      errors[:base] << "invalid cqv - exactly one of related question or list of related questions must be supplied - " +
          "#{related_question_id.inspect},#{related_question_ids.inspect}"
    end
  end

  def self.check(answer)
    cqvs = answer.question.cross_question_validations
    warnings = cqvs.map do |cqv|
      #begin
      cqv.check answer
      #rescue NoMethodError => err
      #  raise NoMethodError, "#{err.message}, Response: #{answer.response.id}, Question: #{answer.question.code}, Answer: #{answer.comparable_answer}, CQV: #{cqv.id} - #{cqv.rule}", caller
      #end
    end
    warnings.compact
  end

  def check(answer)
    checker_params = {operator: operator, constant: constant,
                      set_operator: set_operator, set: set,
                      conditional_operator: conditional_operator, conditional_constant: conditional_constant,
                      conditional_set_operator: conditional_set_operator, conditional_set: conditional_set,
                      related_question_ids: related_question_ids}

    # don't bother checking if the question is unanswered or has an invalid answer
    return nil if answer.nil? or answer.raw_answer

    # we have to filter the answers on the response rather than using find, as we want to check through as-yet unsaved answers as part of batch processing
    related_answer = answer.response.get_answer_to(related_question.id) if related_question

    # most rules are not run unless the related question has been answered, so unless this is a special rule that runs
    # regardless, first check if a related question is relevant, then check if its answered
    if !RULES_THAT_APPLY_EVEN_WHEN_RELATED_ANSWER_NIL.include?(rule)
      return nil if related_question.present? && (related_answer.nil? or related_answer.raw_answer)
    end

    # now actually execute the rule
    error_message unless rule_checkers[rule].call answer, related_answer, checker_params
  end

  def self.register_checker(rule, block)
    # Call register_checker with the rule 'code' of your check.
    # Supply a block that takes the answer and related_answer
    # and returns whether true if the answer meets the rule's criteria
    # The supplied block can assume that no garbage data is stored
    # i.e. that raw_answer is not populated for either answer or related_answer
    rule_checkers[rule] = block
    valid_rules << rule
  end

  private

  cattr_accessor(:rule_checkers) { {} }


  def self.is_operator_safe?(operator)
    SAFE_OPERATORS.include? operator
  end

  def self.is_set_operator_valid?(set_operator)
    ALLOWED_SET_OPERATORS.include? set_operator
  end

  def self.set_meets_condition?(set, set_operator, value)
    return false unless set.is_a?(Array) && value.present?
    return false unless is_set_operator_valid?(set_operator)

    case set_operator
      when 'included'
        return set.include?(value)
      when 'excluded'
        return (!set.include?(value))
      when 'range' # inclusive
        return (value >= set.first && value <= set.last)
      else
        return false
    end
  end

  def self.const_meets_condition?(lhs, operator, rhs)
    if is_operator_safe? operator
      return lhs.send operator, rhs
    else
      return false
    end
  end

  def self.aggregate_date_time(d, t)
    Time.utc_time(d.year, d.month, d.day, t.hour, t.min)
  end

  def self.sanitise_offset(checker_params)
    checker_params[:constant].blank? ? 0 : checker_params[:constant]
  end

  def self.check_gest_wght(answer)
    #TODO Tests kthx
    gest = answer.response.comparable_answer_or_nil_for_question_with_code(GEST_CODE)
    weight = answer.response.comparable_answer_or_nil_for_question_with_code(WGHT_CODE)
    (gest && gest < GEST_LT) || (weight && weight < WGHT_LT)
  end

  register_checker 'comparison', lambda { |answer, related_answer, checker_params|
    break true unless related_answer.answer_value.present?
    offset = sanitise_offset(checker_params)
    const_meets_condition?(answer.comparable_answer, checker_params[:operator], related_answer.answer_with_offset(offset))
  }

  register_checker 'present_implies_constant', lambda { |answer, related_answer, checker_params|
    # e.g. If StartCPAPDate is a date, CPAPhrs must be greater than 0 (answer = CPAPhrs, related = StartCPAPDate)
    # return if related is not present (i.e. not answered or not answered correctly)
    break true unless related_answer && !related_answer.raw_answer
    const_meets_condition?(answer.comparable_answer, checker_params[:operator], checker_params[:constant])
  }

  register_checker 'const_implies_const', lambda { |answer, related_answer, checker_params|
    break true unless answer.answer_value.present? && related_answer.answer_value.present?
    break true unless const_meets_condition?(related_answer.comparable_answer, checker_params[:conditional_operator], checker_params[:conditional_constant])
    const_meets_condition?(answer.comparable_answer, checker_params[:operator], checker_params[:constant])
  }

  register_checker 'const_implies_set', lambda { |answer, related_answer, checker_params|
    break true unless answer.answer_value.present? && related_answer.answer_value.present?
    break true unless const_meets_condition?(related_answer.comparable_answer, checker_params[:conditional_operator], checker_params[:conditional_constant])
    set_meets_condition?(checker_params[:set], checker_params[:set_operator], answer.comparable_answer)
  }

  register_checker 'set_implies_set', lambda { |answer, related_answer, checker_params|
    break true unless answer.comparable_answer.present? && related_answer.comparable_answer.present?
    break true unless set_meets_condition?(checker_params[:conditional_set], checker_params[:conditional_set_operator], related_answer.comparable_answer)
    set_meets_condition?(checker_params[:set], checker_params[:set_operator], answer.comparable_answer)
  }

  register_checker 'blank_if_const', lambda { |answer, related_answer, checker_params|
    # E.g. If Died_ is 0, DiedDate must be blank (rule on DiedDate)

    related_meets_condition = const_meets_condition?(related_answer.comparable_answer, checker_params[:conditional_operator], checker_params[:conditional_constant])
    break true unless related_meets_condition
    # now fail if answer is present
    !answer.comparable_answer.present?
  }

  register_checker 'blank_unless_present', lambda { |answer, related_answer, checker_params|
    break true unless answer.answer_value.present?
    related_answer.present? && related_answer.answer_value.present?
  }

  register_checker 'multi_hours_date_to_date', lambda { |answer, unused_related_answer, checker_params|
    related_ids = checker_params[:related_question_ids]
    date1 = answer.response.get_answer_to(related_ids[0])
    time1 = answer.response.get_answer_to(related_ids[1])
    date2 = answer.response.get_answer_to(related_ids[2])
    time2 = answer.response.get_answer_to(related_ids[3])

    break true if [date1, time1, date2, time2].any? { |related_answer| related_answer.nil? or related_answer.raw_answer }

    offset = sanitise_offset(checker_params)

    datetime1 = aggregate_date_time(date1.answer_value, time1.answer_value)
    datetime2 = aggregate_date_time(date2.answer_value, time2.answer_value)

    hour_difference = (datetime2 - datetime1).abs / 1.hour
    const_meets_condition?(answer.answer_value, checker_params[:operator], hour_difference + offset)
  }

  register_checker 'multi_compare_datetime_quad', lambda { |answer, unused_related_answer, checker_params|
    related_ids = checker_params[:related_question_ids]
    date1 = answer.response.get_answer_to(related_ids[0])
    time1 = answer.response.get_answer_to(related_ids[1])
    date2 = answer.response.get_answer_to(related_ids[2])
    time2 = answer.response.get_answer_to(related_ids[3])

    break true if [date1, time1, date2, time2].any? { |answer| answer.nil? || answer.raw_answer }

    datetime1 = aggregate_date_time(date1.answer_value, time1.answer_value)
    datetime2 = aggregate_date_time(date2.answer_value, time2.answer_value)
    offset = sanitise_offset(checker_params)

    const_meets_condition?(datetime1, checker_params[:operator], datetime2 + offset)
  }

  register_checker 'present_implies_present', lambda { |answer, related_answer, checker_params|
    related_answer && !related_answer.raw_answer
  }

  register_checker 'const_implies_present', lambda { |answer, related_answer, checker_params|
    break true unless const_meets_condition?(answer.comparable_answer, checker_params[:operator], checker_params[:constant])
    # we know the answer meets the criteria, so now just check if related has been answered
    related_answer && !related_answer.raw_answer
  }

  register_checker 'set_implies_present', lambda { |answer, related_answer, checker_params|
    break true unless set_meets_condition?(checker_params[:set], checker_params[:set_operator], answer.comparable_answer)
    # we know the answer meets the criteria, so now just check if related has been answered
    related_answer && !related_answer.raw_answer
  }

  register_checker 'set_present_implies_present', lambda { |answer, unused_related_answer, checker_params|
    # e.g If IVH is 1-4 and USd6wk is a date, Cysts must be between 0 and 4 [which really means cysts must be answered]
    # rule on IVH, related are Usd6wk and Cysts
    related_ids = checker_params[:related_question_ids]
    date = answer.response.get_answer_to(related_ids[0])
    required_answer = answer.response.get_answer_to(related_ids[1])

    #Conditions (IF)
    break true unless set_meets_condition?(checker_params[:set], checker_params[:set_operator], answer.comparable_answer)
    break true unless date && !date.raw_answer

    #Requirements (THEN)
    required_answer.present? && required_answer.raw_answer.blank?
  }

  register_checker 'const_implies_one_of_const', lambda { |answer, related_answer, checker_params|
    break true unless const_meets_condition?(answer.comparable_answer, checker_params[:operator], checker_params[:constant])
    # we know the answer meets the criteria, so now check if any of the related ones have the correct value
    results = checker_params[:related_question_ids].collect do |question_id|
      related_answer = answer.response.get_answer_to(question_id)
      if related_answer
        const_meets_condition?(related_answer.comparable_answer, checker_params[:conditional_operator], checker_params[:conditional_constant])
      else
        false
      end
    end
    results.include?(true)
  }

  register_checker 'set_gest_wght_implies_present', lambda { |answer, related_answer, checker_params|
    # e.g. If IVH is 1-4 and (Gest is <32|Wght is <1500), Ventricles must be between 0 and 3
    # Q = IVH, related = Ventricles
    break true unless set_meets_condition?(checker_params[:set], checker_params[:set_operator], answer.comparable_answer)
    break true unless check_gest_wght(answer)
    related_answer && !related_answer.raw_answer
  }

end
