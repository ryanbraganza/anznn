class CrossQuestionValidation < ActiveRecord::Base
  VALID_RULES = %w(comparison date_implies_constant const_implies_const const_implies_set set_implies_const set_implies_set blank_unless_const blank_unless_set)
  SAFE_OPERATORS = %w(== <= >= < > !=)
  ALLOWED_SET_OPERATORS = %w(included excluded range)

  belongs_to :question
  belongs_to :related_question, class_name: 'Question'

  validates_inclusion_of :rule, in: VALID_RULES
  validates_inclusion_of :operator, in: SAFE_OPERATORS, allow_blank: true

  validates_presence_of :question_id
  validates_presence_of :related_question_id
  validates_presence_of :rule
  validates_presence_of :error_message

  serialize :set, Array
  serialize :conditional_set, Array


  def self.check(answer)
    cqvs = answer.question.cross_question_validations
    warnings = cqvs.map do |cqv|
      cqv.check answer
    end
    warnings.compact
  end

  def check(answer)
    checker_params = {operator: operator, constant: constant,
                      set_operator: set_operator, set: set,
                      conditional_operator: conditional_operator, conditional_constant: conditional_constant,
                      conditional_set_operator: conditional_set_operator, conditional_set: conditional_set}

    # we have to filter the answers on the response rather than using find, as we want to check through as-yet unsaved answers as part of batch processing
    related_answer = answer.response.answers.find { |a| a.question_id == related_question.id }
    if answer.nil? or answer.raw_answer or related_answer.nil? or related_answer.raw_answer
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

    case set_operator
      when 'included'
        return set.include?(value)
      when 'excluded'
        return (!set.include?(value))
      when 'range'
        return (value >= set.first && value <= set.last)
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


  register_checker 'comparison', lambda { |answer, related_answer, checker_params|
    break true unless related_answer.answer_value.present?
    offset = checker_params[:constant].blank? ? 0 : checker_params[:constant]
    const_meets_condition?(answer.answer_value, checker_params[:operator], related_answer.answer_value + offset)
  }

  register_checker 'date_implies_constant', lambda { |answer, related_answer, checker_params|
    break true unless answer.answer_value.is_a?(Date) || answer.answer_value.is_a?(DateInputHandler)
    break true unless related_answer.answer_value.present?
    const_meets_condition?(related_answer.answer_value, checker_params[:operator], checker_params[:constant])
  }

  register_checker 'const_implies_const', lambda { |answer, related_answer, checker_params|
    break true unless related_answer.answer_value.present? && answer.answer_value.present?
    break true unless const_meets_condition?(answer.answer_value, checker_params[:conditional_operator], checker_params[:conditional_constant])
    const_meets_condition?(related_answer.answer_value, checker_params[:operator], checker_params[:constant])
  }

  register_checker 'const_implies_set', lambda { |answer, related_answer, checker_params|
    break true unless related_answer.answer_value.present? && answer.answer_value.present?
    break true unless const_meets_condition?(answer.answer_value, checker_params[:conditional_operator], checker_params[:conditional_constant])
    set_meets_condition?(checker_params[:set], checker_params[:set_operator], related_answer.answer_value)
  }

  register_checker 'set_implies_const', lambda { |answer, related_answer, checker_params|
    break true unless related_answer.answer_value.present? && answer.answer_value.present?
    break true unless set_meets_condition?(checker_params[:conditional_set], checker_params[:conditional_set_operator], answer.answer_value)
    const_meets_condition?(related_answer.answer_value, checker_params[:operator], checker_params[:constant])
  }

  register_checker 'set_implies_set', lambda { |answer, related_answer, checker_params|
    break true unless related_answer.answer_value.present? && answer.answer_value.present?
    break true unless set_meets_condition?(checker_params[:conditional_set], checker_params[:conditional_set_operator], answer.answer_value)
    set_meets_condition?(checker_params[:set], checker_params[:set_operator], related_answer.answer_value)
  }

  register_checker 'blank_unless_const', lambda { |answer, related_answer, checker_params|
    break true unless related_answer.answer_value.present?
    break false unless answer.answer_value.present? # Fails if RHS populated and LHS is blank (hence doesn't meet conditions)

    #we can assume that at this point, we have a value in both, so we just need to see if the lhs rule passes (content in rhs unimportant)
    const_meets_condition?(answer.answer_value, checker_params[:conditional_operator], checker_params[:conditional_constant])

  }

  register_checker 'blank_unless_set', lambda { |answer, related_answer, checker_params|
    break true unless related_answer.answer_value.present?
    break false unless answer.answer_value.present? # Fails if RHS populated and LHS is blank (hence doesn't meet conditions)

    #we can assume that at this point, we have a value in both, so we just need to see if the lhs rule passes (content in rhs unimportant)
    set_meets_condition?(checker_params[:conditional_set], checker_params[:conditional_set_operator], answer.answer_value)

  }


end
