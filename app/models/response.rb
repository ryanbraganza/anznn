class Response < ActiveRecord::Base
  belongs_to :survey
  belongs_to :user
  has_many :answers, dependent: :destroy

  validates_presence_of :baby_code
  validates_presence_of :user
  validates_presence_of :survey_id

  def prepare_answers_to_section(section)
    existing_answers = answers_to_section(section).reduce({}) { |hash, answer| hash[answer.question_id] = answer; hash }

    section.questions.each do |question|
      #if there's no answer object already, build an empty one
      if existing_answers[question.id].nil?
        answer = self.answers.build(question: question)
        existing_answers[question.id] = answer
      end
    end
    existing_answers
  end

  def sections_to_answers
    survey.sections.reduce({}) do |hsh, section|
      answers = prepare_answers_to_section(section).values
      sorted_answers = answers.sort_by {|a| a.question.order }
      hsh.merge section => sorted_answers
    end
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
