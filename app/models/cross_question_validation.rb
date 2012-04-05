class CrossQuestionValidation < ActiveRecord::Base
  VALID_RULES = %w(comparison date_implies_constant const_implies_const const_implies_set set_implies_const set_implies_set)
  SAFE_OPERATORS = %w(== <= >= < > !=)

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

  def self.register_checker(rule, &block)
    # Call register_checker with the rule 'code' of your check.
    # Supply a block that takes the answer and related_answer
    # and returns whether true if the answer meets the rule's criteria
    # The supplied block can assume that no garbage data is stored
    # i.e. that raw_answer is not populated for either answer or related_answer
    rule_checkers[rule] = block
  end


  register_checker 'comparison' do |answer, related_answer, checker_params|
    offset = checker_params[:constant].blank? ? 0 : checker_params[:constant]
    if is_operator_safe? (checker_params[:operator])
      if related_answer.answer_value.present?
        answer.answer_value.send checker_params[:operator], (related_answer.answer_value + offset)
      else
        true
      end
    else
      false
    end
  end

  register_checker 'date_implies_constant' do |answer, related_answer, checker_params|
    if is_operator_safe? (checker_params[:operator])
      if answer.answer_value.is_a?(Date) || answer.answer_value.is_a?(DateInputHandler)
        if related_answer.answer_value.present?
          related_answer.answer_value.send checker_params[:operator], checker_params[:constant]
        else
          true
        end
      else
        true
      end
    else
      false
    end
  end

  register_checker 'const_implies_const' do |answer, related_answer, checker_params|
    if is_operator_safe?(checker_params[:operator]) && is_operator_safe?(checker_params[:conditional_operator])
      if answer.answer_value.send checker_params[:conditional_operator], checker_params[:conditional_constant]
        if related_answer.answer_value.present?
          related_answer.answer_value.send checker_params[:operator], checker_params[:constant]
        else
          true
        end
      else
        true
      end
    else
      false
    end
  end

  register_checker 'const_implies_set' do |answer, related_answer, checker_params|
    if is_operator_safe?(checker_params[:conditional_operator])
      if answer.answer_value.send checker_params[:conditional_operator], checker_params[:conditional_constant]
        if related_answer.answer_value.present?
          included = checker_params[:set].include?(related_answer.answer_value)
          checker_params[:set_operator].eql?("included") ? included : !included
        else
          true
        end
      else
        true
      end
    else
      false
    end
  end

  register_checker 'set_implies_const' do |answer, related_answer, checker_params|
    if is_operator_safe?(checker_params[:operator])
      if answer.answer_value.present?
        set_include = checker_params[:conditional_set_operator].eql?("included")
        set_included = checker_params[:conditional_set].include?(answer.answer_value)
        lhs_meets_conditions = !(set_include ^ set_included) #true if both include/included are the same
        if lhs_meets_conditions
          if related_answer.answer_value.present?
            related_answer.answer_value.send checker_params[:operator], checker_params[:constant]
          else
            true
          end
        else
          true
        end
      else
        true
      end
    else
      false
    end
  end

  register_checker 'set_implies_set' do |answer, related_answer, checker_params|
    if is_operator_safe?(checker_params[:operator])
      if answer.answer_value.present?
        set_include = checker_params[:conditional_set_operator].eql?("included")
        set_included = checker_params[:conditional_set].include?(answer.answer_value)
        lhs_meets_conditions = !(set_include ^ set_included) #true if both include/included are the same
        if lhs_meets_conditions
          if related_answer.answer_value.present?
            included = checker_params[:set].include?(related_answer.answer_value)
            checker_params[:set_operator].eql?("included") ? included : !included
          else
            true
          end
        else
          true
        end
      else
        true
      end
    else
      false
    end
  end


end
