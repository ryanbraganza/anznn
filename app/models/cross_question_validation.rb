class CrossQuestionValidation < ActiveRecord::Base
  VALID_RULES =
      %w(comparison
    date_implies_constant const_implies_const const_implies_set set_implies_const set_implies_set
    blank_unless_const blank_unless_set blank_unless_days_const
    multi_rule_any_pass multi_rule_if_then
    multi_hours_date_to_date multi_compare_datetime_quad)

  SAFE_OPERATORS = %w(== <= >= < > !=)
  ALLOWED_SET_OPERATORS = %w(included excluded range between)

  belongs_to :question
  belongs_to :related_question, class_name: 'Question'

  validates_inclusion_of :rule, in: VALID_RULES
  validates_inclusion_of :operator, in: SAFE_OPERATORS, allow_blank: true

  validates_presence_of :question_id
  validate :one_of_related_or_list_or_labels
  validates_presence_of :rule
  validates_presence_of :error_message
  validates_inclusion_of :primary, in: [true, false]

  serialize :related_rule_ids, Array
  serialize :related_question_ids, Array
  serialize :set, Array
  serialize :conditional_set, Array

  def one_of_related_or_list_or_labels
    unless [related_question_id, related_question_ids, related_rule_ids].select(&:present?).count == 1
      errors[:base] << "invalid cqv - only one of related question, list of questions or list of rules - " +
          "#{related_question_id.inspect},#{related_question_ids.inspect},#{related_rule_ids.inspect}"
    end
  end

  def self.check(answer)
    cqvs = answer.question.cross_question_validations
    warnings = cqvs.map do |cqv|
      cqv.check answer
    end
    warnings.compact
  end

  def check(answer, running_as_secondary = false)
    checker_params = {operator: operator, constant: constant,
                      set_operator: set_operator, set: set,
                      conditional_operator: conditional_operator, conditional_constant: conditional_constant,
                      conditional_set_operator: conditional_set_operator, conditional_set: conditional_set,
                      related_rule_ids: related_rule_ids, related_question_ids: related_question_ids}

    # we have to filter the answers on the response rather than using find, as we want to check through as-yet unsaved answers as part of batch processing
    related_answer = answer.response.answers.find { |a| a.question_id == related_question.id } if related_question

    # if not a primary rule, nil
    # if we dont have a proper answer, nil
    # if we only have one related question, if that doesn't have a proper answer: nil

    return nil unless self.primary? || running_as_secondary

    if answer.nil? or answer.raw_answer
      nil
    elsif related_question.present? && (related_answer.nil? or related_answer.raw_answer)
      nil
    else
      error_message unless rule_checkers[rule].call answer, related_answer, checker_params
    end
  end

  private

  cattr_accessor(:rule_checkers) { {} }


  def self.is_operator_safe?(operator)
    SAFE_OPERATORS.include? operator
  end

  def self.is_set_operator_valid?(set_operator)
    ALLOWED_SET_OPERATORS.include? set_operator
  end

  def self.register_checker(rule, block)
    # Call register_checker with the rule 'code' of your check.
    # Supply a block that takes the answer and related_answer
    # and returns whether true if the answer meets the rule's criteria
    # The supplied block can assume that no garbage data is stored
    # i.e. that raw_answer is not populated for either answer or related_answer
    rule_checkers[rule] = block
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
      when 'between' #exclusive
        return (value > set.first && value < set.last)
      else
        return false
    end
  end

  def self.const_meets_condition?(lhs, operator, rhs, offset = 0)
    if is_operator_safe? operator
      return lhs.send operator, rhs + offset
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

  def self.collect_multiple_answers(answer, checker_params)
    answers = answer.response.answers.find_all_by_question_id(checker_params[:related_question_ids])
    answers.sort_by { |a| checker_params[:related_question_ids].index(a.question_id) }
  end

  register_checker 'comparison', lambda { |answer, related_answer, checker_params|
    break true unless related_answer.answer_value.present?
    offset = sanitise_offset(checker_params)
    if answer.answer_value.is_a?(String) || related_answer.answer_value.is_a?(String)
      const_meets_condition?(answer.answer_value.to_i, checker_params[:operator], related_answer.answer_value.to_i + offset)
    else
      const_meets_condition?(answer.answer_value, checker_params[:operator], related_answer.answer_value + offset)
    end
  }

  register_checker 'date_implies_constant', lambda { |answer, related_answer, checker_params|
    break true unless related_answer.answer_value.is_a?(Date) || related_answer.answer_value.is_a?(DateInputHandler)
    break true unless answer.answer_value.present?
    const_meets_condition?(answer.answer_value, checker_params[:operator], checker_params[:constant])
  }

  register_checker 'const_implies_const', lambda { |answer, related_answer, checker_params|
    break true unless answer.answer_value.present? && related_answer.answer_value.present?
    break true unless const_meets_condition?(related_answer.answer_value, checker_params[:conditional_operator], checker_params[:conditional_constant])
    if answer.answer_value.is_a?(String) || related_answer.answer_value.is_a?(String)
      const_meets_condition?(answer.answer_value.to_i, checker_params[:operator], checker_params[:constant])
    else
      const_meets_condition?(answer.answer_value, checker_params[:operator], checker_params[:constant])
    end
  }

  register_checker 'const_implies_set', lambda { |answer, related_answer, checker_params|
    break true unless answer.answer_value.present? && related_answer.answer_value.present?
    if answer.answer_value.is_a?(String) || related_answer.answer_value.is_a?(String)
      break true unless const_meets_condition?(related_answer.answer_value.to_i, checker_params[:conditional_operator], checker_params[:conditional_constant])
    else
      break true unless const_meets_condition?(related_answer.answer_value, checker_params[:conditional_operator], checker_params[:conditional_constant])
    end
    set_meets_condition?(checker_params[:set], checker_params[:set_operator], answer.answer_value)
  }

  register_checker 'set_implies_const', lambda { |answer, related_answer, checker_params|
    break true unless answer.answer_value.present? && related_answer.answer_value.present?
    break true unless set_meets_condition?(checker_params[:conditional_set], checker_params[:conditional_set_operator], related_answer.answer_value)
    const_meets_condition?(answer.answer_value, checker_params[:operator], checker_params[:constant])
  }

  register_checker 'set_implies_set', lambda { |answer, related_answer, checker_params|
    break true unless answer.answer_value.present? && related_answer.answer_value.present?
    break true unless set_meets_condition?(checker_params[:conditional_set], checker_params[:conditional_set_operator], related_answer.answer_value)
    set_meets_condition?(checker_params[:set], checker_params[:set_operator], answer.answer_value)
  }

  register_checker 'blank_unless_const', lambda { |answer, related_answer, checker_params|
    break true unless answer.answer_value.present?
    break false unless related_answer.answer_value.present? # Fails if RHS populated and LHS is blank (hence doesn't meet conditions)

    #we can assume that at this point, we have a value in both, so we just need to see if the lhs rule passes (content in rhs unimportant)
    const_meets_condition?(related_answer.answer_value, checker_params[:conditional_operator], checker_params[:conditional_constant])

  }

  register_checker 'blank_unless_set', lambda { |answer, related_answer, checker_params|
    break true unless answer.answer_value.present?
    break false unless related_answer.answer_value.present? # Fails if RHS populated and LHS is blank (hence doesn't meet conditions)

    #we can assume that at this point, we have a value in both, so we just need to see if the lhs rule passes (content in rhs unimportant)
    set_meets_condition?(checker_params[:conditional_set], checker_params[:conditional_set_operator], related_answer.answer_value)

  }

  register_checker 'multi_rule_any_pass', lambda { |answer, related_answer, checker_params|
    rules = CrossQuestionValidation.find(checker_params[:related_rule_ids])

    rules.each do |rule|
      err = rule.check(answer, true)
      return true if !err
    end

    false
  }

  #this only accepts two rules - the IF rule and the THEN rule
  register_checker 'multi_rule_if_then', lambda { |answer, related_answer, checker_params|

    rules = CrossQuestionValidation.find(checker_params[:related_rule_ids])

    err1 = rules.shift.check(answer, true)
    break true if err1.present?

    err2 = rules.last.check(answer, true)
    err2.blank?

  }

  register_checker 'multi_hours_date_to_date', lambda { |answer, unused_related_answer, checker_params|
    answers = collect_multiple_answers(answer, checker_params)

    break true if answers.map { |related_answer| related_answer.nil? or related_answer.raw_answer }.any?

    date1, time1, date2, time2 = answers

    offset = sanitise_offset(checker_params)

    datetime1 = aggregate_date_time(date1.answer_value, time1.answer_value)
    datetime2 = aggregate_date_time(date2.answer_value, time2.answer_value)
    hour_difference = (datetime2 - datetime1) / 1.hour

    const_meets_condition?(answer.answer_value, checker_params[:operator], hour_difference + offset)
  }

  register_checker 'multi_compare_datetime_quad', lambda { |answer, unused_related_answer, checker_params|
    answers = collect_multiple_answers(answer, checker_params)

    break true if answers.map { |related_answer| related_answer.nil? or related_answer.raw_answer }.any?

    date1, time1, date2, time2 = answers

    datetime1 = aggregate_date_time(date1.answer_value, time1.answer_value)
    datetime2 = aggregate_date_time(date2.answer_value, time2.answer_value)
    offset = sanitise_offset(checker_params)

    const_meets_condition?(datetime1, checker_params[:operator], datetime2 + offset)
  }


  register_checker 'blank_unless_days_const', lambda { |answer, unused_related_answer, checker_params|
    answers = collect_multiple_answers(answer, checker_params)

    break true if answers.map { |related_answer| related_answer.nil? or related_answer.date_answer.nil? }.any?

    date1, date2 = answers

    day_difference = (date2.answer_value - date1.answer_value).to_i

    const_meets_condition?(day_difference, checker_params[:conditional_operator], checker_params[:conditional_constant])
  }

end
