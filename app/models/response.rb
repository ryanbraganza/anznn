class Response < ActiveRecord::Base
  belongs_to :survey
  belongs_to :user
  has_many :answers, dependent: :destroy

  validates_presence_of :baby_code
  validates_presence_of :user
  validates_presence_of :survey_id

  def question_id_to_answers
    answers.reduce({}) { |hash, answer| hash[answer.question_id] = answer; hash }
  end

  def compute_warnings
    answers.each { |a| a.compute_warnings }
  end

  def section_started?(section)
    !answers_to_section(section).empty?
  end

  def status_of_section(section)
    if section_started?(section)
      answers_to_section = answers_to_section(section)
      required_question_ids = section.questions.where(:mandatory => true).collect(&:id)
      answered_question_ids = answers_to_section.collect(&:question_id)
      all_mandatory_questions_answered = (required_question_ids - answered_question_ids).empty?
      return "Incomplete" unless all_mandatory_questions_answered
      any_warnings = answers_to_section.collect(&:has_warning?).include?(true)
      return "Incomplete" if any_warnings
      "Complete"
    else
      "Not started"
    end
  end

  private

  def answers_to_section(section)
    answers.joins(:question).merge(Question.for_section(section))
  end
end
