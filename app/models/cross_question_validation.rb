class CrossQuestionValidation < ActiveRecord::Base

  RULES_WITH_NO_RELATED = %w(special_dob
                             self_comparison
                             special_rop_prem_rop_vegf_1
                             special_rop_prem_rop_vegf_2
                             special_rop_prem_rop
                             special_rop_prem_rop_retmaturity
                             special_rop_prem_rop_roprx_1
                             special_rop_prem_rop_roprx_2
                             special_namesurg2
                             special_namesurg3
                             special_immun
                             special_cool_hours
                             special_date_of_assess
                             special_height
                             special_length
                             special_cochimplt)

  VALID_RULES =
      %w(comparison
         present_implies_constant
         const_implies_const
         const_implies_set
         set_implies_const
         set_implies_set
         blank_if_const
         blank_unless_set
         blank_unless_days_const
         blank_unless_present
         multi_rule_any_pass
         multi_rule_if_then
         multi_hours_date_to_date
         multi_compare_datetime_quad
         present_implies_present
         const_implies_present
         set_implies_present
         const_implies_one_of_const
         special_dual_comparison
         special_o2_a
         special_usd6wk_dob_weeks
         set_gest_wght_implies_set
         set_gest_wght_implies_present
         set_present_implies_present
         comparison_const_days) + RULES_WITH_NO_RELATED

  RULES_THAT_APPLY_EVEN_WHEN_ANSWER_NIL = %w(special_dual_comparison)
  RULES_THAT_APPLY_EVEN_WHEN_RELATED_ANSWER_NIL = %w(present_implies_present const_implies_present set_implies_present special_dual_comparison blank_unless_present set_gest_wght_implies_present)

  SAFE_OPERATORS = %w(== <= >= < > !=)
  ALLOWED_SET_OPERATORS = %w(included excluded range)

  GEST_CODE = 'Gest'
  GEST_DAYS_CODE = 'GestDays'
  WGHT_CODE = 'Wght'
  DOB_CODE = 'DOB'
  LAST_O2_CODE = 'LastO2'
  CEASE_CPAP_DATE_CODE = 'CeaseCPAPDate'
  CEASE_HI_FLO_DATE_CODE = 'CeaseHiFloDate'


  GEST_LT = 32
  WGHT_LT = 1500

  belongs_to :question
  belongs_to :related_question, class_name: 'Question'

  validates_inclusion_of :rule, in: VALID_RULES
  validates_inclusion_of :operator, in: SAFE_OPERATORS, allow_blank: true

  validates_presence_of :question_id
  validate :one_of_related_or_list_or_labels
  validates_presence_of :rule
  validates_presence_of :error_message, :if => :primary?
  validates_inclusion_of :primary, in: [true, false]

  serialize :related_rule_ids, Array
  serialize :related_question_ids, Array
  serialize :set, Array
  serialize :conditional_set, Array

  def one_of_related_or_list_or_labels
    return if RULES_WITH_NO_RELATED.include?(rule)
    unless [related_question_id, related_question_ids, related_rule_ids].count(&:present?) == 1
      errors[:base] << "invalid cqv - only one of related question, list of questions or list of rules - " +
          "#{related_question_id.inspect},#{related_question_ids.inspect},#{related_rule_ids.inspect}"
    end
  end

  def self.check(answer)
    cqvs = answer.question.cross_question_validations
    warnings = cqvs.map do |cqv|
      begin
        cqv.check answer
      rescue NoMethodError => err
        raise NoMethodError, "#{err.message}, Response: #{answer.response.id}, Question: #{answer.question.code}, Answer: #{answer.comparable_answer}, CQV: #{cqv.id} - #{cqv.rule}", caller
      end
    end
    warnings.compact
  end

  def check(answer, running_as_secondary = false)
    checker_params = {operator: operator, constant: constant,
                      set_operator: set_operator, set: set,
                      conditional_operator: conditional_operator, conditional_constant: conditional_constant,
                      conditional_set_operator: conditional_set_operator, conditional_set: conditional_set,
                      related_rule_ids: related_rule_ids, related_question_ids: related_question_ids}

    # don't bother checking if the question is unanswered or has an invalid answer
    if !RULES_THAT_APPLY_EVEN_WHEN_ANSWER_NIL.include?(rule)
      return nil if answer.nil? or answer.raw_answer
    end

    # if not a primary rule, nil
    return nil unless self.primary? || running_as_secondary

    # we have to filter the answers on the response rather than using find, as we want to check through as-yet unsaved answers as part of batch processing
    related_answer = answer.response.get_answer_to(related_question.id) if related_question

    # most rules are not run unless the related question has been answered, so unless this is a special rule that runs
    # regardless, first check if a related question is relevant, then check if its answered
    if !RULES_THAT_APPLY_EVEN_WHEN_RELATED_ANSWER_NIL.include?(rule)
      return nil if related_question.present? && (related_answer.nil? or related_answer.raw_answer)
    end

    # Auto-generate an error message if secondary rules don't have one:
    sanitised_error = error_message.present? ? error_message : "Failure in #{rule}"

    # now actually execute the rule
    sanitised_error unless rule_checkers[rule].call answer, related_answer, checker_params
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

  register_checker 'set_implies_const', lambda { |answer, related_answer, checker_params|
    break true unless answer.answer_value.present? && related_answer.answer_value.present?
    break true unless set_meets_condition?(checker_params[:conditional_set], checker_params[:conditional_set_operator], related_answer.comparable_answer)
    const_meets_condition?(answer.comparable_answer, checker_params[:operator], checker_params[:constant])
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

  register_checker 'blank_unless_set', lambda { |answer, related_answer, checker_params|
    break true unless answer.answer_value.present?
    break false unless related_answer.answer_value.present? # Fails if RHS populated and LHS is blank (hence doesn't meet conditions)

    #we can assume that at this point, we have a value in both, so we just need to see if the lhs rule passes (content in rhs unimportant)
    set_meets_condition?(checker_params[:conditional_set], checker_params[:conditional_set_operator], related_answer.comparable_answer)

  }

  register_checker 'blank_unless_present', lambda { |answer, related_answer, checker_params|
    break true unless answer.answer_value.present?
    related_answer.present? && related_answer.answer_value.present?
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

    rule1 = CrossQuestionValidation.find(checker_params[:related_rule_ids].first)
    rule2 = CrossQuestionValidation.find(checker_params[:related_rule_ids].last)

    answer1 = answer.response.get_answer_to(rule1.question.id) if rule1.question
    answer2 = answer.response.get_answer_to(rule2.question.id) if rule2.question

    err1 = rule1.check(answer1, true)
    break true if err1.present?

    err2 = rule2.check(answer2, true)
    err2.blank?

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
    hour_difference = (datetime2 - datetime1) / 1.hour

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

  register_checker 'blank_unless_days_const', lambda { |answer, unused_related_answer, checker_params|
    related_ids = checker_params[:related_question_ids]
    date1 = answer.response.get_answer_to(related_ids[0])
    date2 = answer.response.get_answer_to(related_ids[1])

    break true if [date1, date2].any? { |related_answer| related_answer.nil? or related_answer.date_answer.nil? }

    day_difference = (date2.answer_value - date1.answer_value).to_i

    const_meets_condition?(day_difference, checker_params[:conditional_operator], checker_params[:conditional_constant])
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
    required = answer.response.get_answer_to(related_ids[1])

    break true unless set_meets_condition?(checker_params[:set], checker_params[:set_operator], answer.comparable_answer)
    break true unless date && !date.raw_answer
    required && !required.raw_answer
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

# special rules

  register_checker 'special_dual_comparison', lambda { |answer, related_answer, checker_params|
    first = answer.comparable_answer.blank? ? false : const_meets_condition?(answer.comparable_answer,
                                                                             checker_params[:operator],
                                                                             checker_params[:constant])
    second = related_answer.comparable_answer.blank? ? false : const_meets_condition?(related_answer.comparable_answer,
                                                                                      checker_params[:conditional_operator],
                                                                                      checker_params[:conditional_constant])
    (first || second)
  }

  register_checker 'self_comparison', lambda { |answer, unused_related_answer, checker_params|
    const_meets_condition?(answer.comparable_answer, checker_params[:operator], checker_params[:constant])
  }


  register_checker 'special_o2_a', lambda { |answer, unused_related_answer, checker_params|
    raise 'Can only be used on question O2_36_wk_' unless answer.question.code == 'O2_36_wk_'

    #If O2_36wk_ is -1 and (Gest must be <32 or Wght must be <1500) and (Gest+Gestdays + weeks(DOB and the latest date of (LastO2|CeaseCPAPDate|CeaseHiFloDate))) >36
    break true unless (answer.comparable_answer == -1)

    # ok if not premature
    break true unless check_gest_wght(answer)

    gest = answer.response.comparable_answer_or_nil_for_question_with_code(GEST_CODE)
    gest_days = answer.response.comparable_answer_or_nil_for_question_with_code(GEST_DAYS_CODE)
    dob = answer.response.comparable_answer_or_nil_for_question_with_code(DOB_CODE)

    last_o2 = answer.response.comparable_answer_or_nil_for_question_with_code(LAST_O2_CODE)
    cease_cpap_date = answer.response.comparable_answer_or_nil_for_question_with_code(CEASE_CPAP_DATE_CODE)
    cease_hi_flo_date = answer.response.comparable_answer_or_nil_for_question_with_code(CEASE_HI_FLO_DATE_CODE)

    break false unless dob.present?
    break false unless gest.present?
    break false unless gest_days.present?
    break false unless last_o2.present? || cease_cpap_date.present || cease_hi_flo_date.present?

    dates = [last_o2, cease_cpap_date, cease_hi_flo_date]
    dates.compact.sort!
    max_elapsed = dates.last - dob

    #The actual test (gest in in weeks)
    gest.weeks + gest_days.days + max_elapsed.to_i.days > 36.weeks
  }

  register_checker 'special_dob', lambda { |answer, unused_related_answer, checker_params|
    answer.date_answer.year == answer.response.year_of_registration
  }

  register_checker 'special_rop_prem_rop_vegf_1', lambda { |answer, ununused_related_answer, checker_params|
    #If ROPeligibleExam is -1 and (Gest is <32|Wght is <1500) and ROP is between 1 and 4, ROP_VEGF must be 0 or -1

    # if the answer is 0 or -1, no need to check further
    break true if [0, -1].include?(answer.comparable_answer)

    break true unless answer.response.comparable_answer_or_nil_for_question_with_code('ROPeligibleExam') == -1
    break true unless (1..4).include?(answer.response.comparable_answer_or_nil_for_question_with_code('ROP'))
    break true unless check_gest_wght(answer)
    # if we get here, all the conditions are met, and ROP_VEGF is not 0 or -1, so its an error
    false
  }

  register_checker 'special_rop_prem_rop_vegf_2', lambda { |answer, ununused_related_answer, checker_params|
    #If ROPeligibleExam is -1 and (Gest is <32|Wght is <1500) and ROP is 0, ROP_VEGF must be 0

    # if the answer is 0, no need to check further
    break true if answer.comparable_answer == 0

    break true unless answer.response.comparable_answer_or_nil_for_question_with_code('ROPeligibleExam') == -1
    break true unless answer.response.comparable_answer_or_nil_for_question_with_code('ROP') == 0
    break true unless check_gest_wght(answer)
    # if we get here, all the conditions are met, and ROP_VEGF is not 0, so its an error
    false
  }

  register_checker 'special_rop_prem_rop', lambda { |answer, ununused_related_answer, checker_params|
    #If ROPeligibleExam is -1 and (Gest is <32|Wght is <1500), ROP must be between 0 and 4

    # if the answer is 1..4, no need to check further
    break true if (0..4).include?(answer.comparable_answer)

    break true unless answer.response.comparable_answer_or_nil_for_question_with_code('ROPeligibleExam') == -1
    break true unless check_gest_wght(answer)
    # if we get here, all the conditions are met, and ROP is not 0..4, so its an error
    false
  }

  register_checker 'special_rop_prem_rop_retmaturity', lambda { |answer, ununused_related_answer, checker_params|
    #If ROPeligibleExam is -1 and (Gest is <32|Wght is <1500) and ROP is between 0 and 4, Retmaturity must be -1 or 0

    # if the answer is -1 or 0, no need to check further
    break true if [0, -1].include?(answer.comparable_answer)

    break true unless answer.response.comparable_answer_or_nil_for_question_with_code('ROPeligibleExam') == -1
    break true unless (0..4).include?(answer.response.comparable_answer_or_nil_for_question_with_code('ROP'))
    break true unless check_gest_wght(answer)
    # if we get here, all the conditions are met, and ROP is not 1..4, so its an error
    false
  }

  register_checker 'special_rop_prem_rop_roprx_1', lambda { |answer, ununused_related_answer, checker_params|
    #If ROPeligibleExam is -1 and (Gest is <32|Wght is <1500) and ROP is 0 or 1 or 5, ROPRx must be 0

    # if the answer is -1 or 0, no need to check further
    break true if answer.comparable_answer == 0

    break true unless answer.response.comparable_answer_or_nil_for_question_with_code('ROPeligibleExam') == -1
    break true unless [0, 1, 5].include?(answer.response.comparable_answer_or_nil_for_question_with_code('ROP'))
    break true unless check_gest_wght(answer)
    # if we get here, all the conditions are met, and ROP is not 1..4, so its an error
    false
  }

  register_checker 'special_rop_prem_rop_roprx_2', lambda { |answer, ununused_related_answer, checker_params|
    #If ROPeligibleExam is -1 and (Gest is <32|Wght is <1500) and ROP is 3 or 4, ROPRx must be -1

    # if the answer is -1 or 0, no need to check further
    break true if answer.comparable_answer == -1

    break true unless answer.response.comparable_answer_or_nil_for_question_with_code('ROPeligibleExam') == -1
    break true unless [3, 4].include?(answer.response.comparable_answer_or_nil_for_question_with_code('ROP'))
    break true unless check_gest_wght(answer)
    # if we get here, all the conditions are met, and ROP is not 1..4, so its an error
    false
  }

  register_checker 'set_gest_wght_implies_set', lambda { |answer, related_answer, checker_params|
    break true unless related_answer.comparable_answer.present?
    break true unless set_meets_condition?(checker_params[:conditional_set], checker_params[:conditional_set_operator], related_answer.comparable_answer)
    break true unless check_gest_wght(answer)
    break false unless answer.comparable_answer.present? # Fail if all conditions have been met so far, but we don't have an answer yet.
    set_meets_condition?(checker_params[:set], checker_params[:set_operator], answer.comparable_answer)
  }

  register_checker 'special_usd6wk_dob_weeks', lambda { |answer, related_answer, checker_params|
    break true unless related_answer.comparable_answer.present?
    dob = answer.response.comparable_answer_or_nil_for_question_with_code(DOB_CODE)
    break true unless dob
    break true unless set_meets_condition?(checker_params[:conditional_set], checker_params[:conditional_set_operator], related_answer.comparable_answer)
    break true unless check_gest_wght(answer)
    break false unless answer.comparable_answer.present? # Fail if all conditions have been met so far, but we don't have an answer yet.

    elapsed_weeks = (answer.comparable_answer - dob).abs.days / 1.week
    set_meets_condition?(checker_params[:set], checker_params[:set_operator], elapsed_weeks)
  }

  register_checker 'set_gest_wght_implies_present', lambda { |answer, related_answer, checker_params|
    # e.g. If IVH is 1-4 and (Gest is <32|Wght is <1500), Ventricles must be between 0 and 3
    # Q = IVH, related = Ventricles
    break true unless set_meets_condition?(checker_params[:set], checker_params[:set_operator], answer.comparable_answer)
    break true unless check_gest_wght(answer)
    related_answer && !related_answer.raw_answer
  }

  register_checker 'special_namesurg2', lambda { |answer, ununused_related_answer, checker_params|
    #If DateSurg2=DateSurg1, NameSurg2 must not be the same as NameSurg1 (rule is on NameSurg2)
    raise 'Can only be used on question NameSurg2' unless answer.question.code == 'NameSurg2'

    datesurg1 = answer.response.comparable_answer_or_nil_for_question_with_code('DateSurg1')
    datesurg2 = answer.response.comparable_answer_or_nil_for_question_with_code('DateSurg2')
    break true unless (datesurg1 && datesurg2 && (datesurg1 == datesurg2))
    namesurg1 = answer.response.comparable_answer_or_nil_for_question_with_code('NameSurg1')
    break true unless namesurg1 == answer.comparable_answer
  }

  register_checker 'special_namesurg3', lambda { |answer, ununused_related_answer, checker_params|
    #If DateSurg3=DateSurg2, NameSurg3 must not be the same as NameSurg2 (rule is on NameSurg3)
    raise 'Can only be used on question NameSurg3' unless answer.question.code == 'NameSurg3'

    datesurg2 = answer.response.comparable_answer_or_nil_for_question_with_code('DateSurg2')
    datesurg3 = answer.response.comparable_answer_or_nil_for_question_with_code('DateSurg3')
    break true unless (datesurg2 && datesurg3 && (datesurg2 == datesurg3))
    namesurg2 = answer.response.comparable_answer_or_nil_for_question_with_code('NameSurg2')
    break true unless namesurg2 == answer.comparable_answer
  }

  register_checker 'comparison_const_days', lambda { |answer, related_answer, checker_params|
    break true unless related_answer.date_answer.present? && answer.date_answer.present?
    delta_days = (related_answer.date_answer - answer.date_answer).to_i.abs
    const_meets_condition?(delta_days, checker_params[:operator], checker_params[:constant])
  }

  register_checker 'special_cool_hours', lambda { |answer, ununused_related_answer, checker_params|
    #hours between |StartCoolDate+StartCoolTime - CeaseCoolDate+CeaseCoolTime| <=72
    raise 'Can only be used on question StartCoolDate' unless answer.question.code == 'StartCoolDate'

    start_cool_date = answer.response.comparable_answer_or_nil_for_question_with_code('StartCoolDate')
    start_cool_time = answer.response.comparable_answer_or_nil_for_question_with_code('StartCoolTime')
    cease_cool_date = answer.response.comparable_answer_or_nil_for_question_with_code('CeaseCoolDate')
    cease_cool_time = answer.response.comparable_answer_or_nil_for_question_with_code('CeaseCoolTime')
    break true unless start_cool_date && start_cool_time && cease_cool_date && cease_cool_time

    datetime1 = aggregate_date_time(start_cool_date, start_cool_time)
    datetime2 = aggregate_date_time(cease_cool_date, cease_cool_time)
    hour_difference = (datetime2 - datetime1) / 1.hour

    hour_difference <= 72
  }

  register_checker 'special_immun', lambda { |answer, ununused_related_answer, checker_params|
    #If Gest<32|Wght<1500 and days(DOB and HomeDate|DiedDate)>=60, DateImmun must be a date
    # dob is the best place to put this, even though its a bit weird
    raise 'Can only be used on question DOB' unless answer.question.code == 'DOB'

    # we're ok if DateImmun is filled
    break true if answer.response.comparable_answer_or_nil_for_question_with_code('DateImmun')
    # ok if not premature
    break true unless check_gest_wght(answer)

    home_date = answer.response.comparable_answer_or_nil_for_question_with_code('HomeDate')
    died_date = answer.response.comparable_answer_or_nil_for_question_with_code('DiedDate')
    # if home date is filled, use that
    if home_date
      days_diff = (home_date - answer.answer_value).to_i
      days_diff < 60
    elsif died_date
      # if died date is filled, use that
      days_diff = (died_date - answer.answer_value).to_i
      days_diff < 60
    else
      # neither is filled, its ok
      true
    end
  }

  register_checker 'special_date_of_assess', lambda { |answer, ununused_related_answer, checker_params|
    #DateOfAssess must be greater than DOB+24 months (rule is on DateOfAssess)
    raise 'Can only be used on question DateOfAssess' unless answer.question.code == 'DateOfAssess'

    dob = answer.response.comparable_answer_or_nil_for_question_with_code('DOB')

    break true unless dob
    answer.answer_value > (dob + 24.months)
  }

  register_checker 'special_height', lambda { |answer, ununused_related_answer, checker_params|
    #If years between DOB and DateOfAssess is greater than 3, Hght must be between 50 and 100 (rule on Hght)
    raise 'Can only be used on question Hght' unless answer.question.code == 'Hght'

    dob = answer.response.comparable_answer_or_nil_for_question_with_code('DOB')
    doa = answer.response.comparable_answer_or_nil_for_question_with_code('DateOfAssess')
    break true unless dob && doa

    if doa > (dob + 3.years)
      answer.comparable_answer >= 50 && answer.comparable_answer <= 100
    else
      true
    end
  }


  register_checker 'special_length', lambda { |answer, ununused_related_answer, checker_params|
    #If years between DOB and DateOfAssess is less than or equal to 3, than Length must be between 50 and 100 (rule on Length)
    raise 'Can only be used on question Length' unless answer.question.code == 'Length'

    dob = answer.response.comparable_answer_or_nil_for_question_with_code('DOB')
    doa = answer.response.comparable_answer_or_nil_for_question_with_code('DateOfAssess')
    break true unless dob && doa

    if doa <= (dob + 3.years)
      answer.comparable_answer >= 50 && answer.comparable_answer <= 100
    else
      true
    end
  }

  register_checker 'special_cochimplt', lambda { |answer, ununused_related_answer, checker_params|
    #If Heartest is 2 or 4 and Hearaid is 1 or 2, Cochlmplt must be 1 or 2 (rule on CochImplt)
    raise 'Can only be used on question CochImplt' unless answer.question.code == 'CochImplt'

    heartest = answer.response.comparable_answer_or_nil_for_question_with_code('Heartest')
    hearaid = answer.response.comparable_answer_or_nil_for_question_with_code('Hearaid')
    break true unless heartest && [2, 4].include?(heartest) && hearaid && [1, 2].include?(hearaid)
    [1, 2].include?(answer.comparable_answer)
  }
end
