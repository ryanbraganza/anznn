class CrossQuestionValidation < ActiveRecord::Base
  belongs_to :question
  belongs_to :related_question, class_name: 'Question'

  validates_inclusion_of :rule, in: ['date_gte', 'date_gt', 'date_lt', 'date_lte']

  validates_presence_of :question_id
  validates_presence_of :related_question_id
  validates_presence_of :rule
  validates_presence_of :error_message

  def self.check(answer)
    cqvs = answer.question.cross_question_validations
    warnings = cqvs.map do |cqv|
      cqv.check answer
    end
    warnings.compact
  end

  def check(answer)
    # we have to filter the answers on the response rather than using find, as we want to check through as-yet unsaved answers as part of batch processing
    related_answer = answer.response.answers.find { |a| a.question_id == related_question.id }
    if answer.nil? or answer.raw_answer or related_answer.nil? or related_answer.raw_answer
      nil
    else
      error_message unless rule_checkers[rule].call answer, related_answer
    end
  end
  
  private

  cattr_accessor(:rule_checkers){{}}
 
  def self.register_checker(rule, &block)
    # Call register_checker with the rule 'code' of your check.
    # Supply a block that takes the answer and related_answer
    # and returns whether true if the answer meets the rule's criteria
    # The supplied block can assume that no garbage data is stored
    # i.e. that raw_answer is not populated for either answer or related_answer
    rule_checkers[rule] = block
  end

  register_checker 'date_lte' do |answer, related_answer|
    answer.date_answer <= related_answer.date_answer
  end

  register_checker 'date_gte' do |answer, related_answer|
    answer.date_answer >= related_answer.date_answer
  end

  register_checker 'date_lt' do |answer, related_answer|
    answer.date_answer < related_answer.date_answer
  end

  register_checker 'date_gt' do |answer, related_answer|
    answer.date_answer > related_answer.date_answer
  end
end
