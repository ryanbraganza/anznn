class Response < ActiveRecord::Base

  STATUS_UNSUBMITTED = 'Unsubmitted'
  STATUS_SUBMITTED = 'Submitted'

  COMPLETE = 'Complete'
  NOT_STARTED = 'Not started'
  INCOMPLETE = 'Incomplete'
  COMPLETE_WITH_WARNINGS = 'Complete with warnings'

  belongs_to :survey
  belongs_to :user
  belongs_to :hospital

  has_many :answers, dependent: :destroy

  validates_presence_of :baby_code
  validates_presence_of :user
  validates_presence_of :survey_id
  validates_presence_of :hospital_id
  validates_inclusion_of :submitted_status, in: [STATUS_UNSUBMITTED, STATUS_SUBMITTED]

  def submit!
    if ![COMPLETE, COMPLETE_WITH_WARNINGS].include?(status)
      raise "Can't submit with status #{status}"
    end
    self.submitted_status = STATUS_SUBMITTED
    self.save!
  end

  def submit_warning
    # This method is role-ignorant.
    # Use cancan to check if a response is not submittable before trying to display this
    case status
    when INCOMPLETE
      "This survey is incomplete and can't be submitted."
    when COMPLETE_WITH_WARNINGS
      "This survey has warnings. Double check them. If you believe them to be correct, contact a supervisor."
    else
      nil
    end
  end

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
      answers = all_answers_for_section(section)
      sorted_answers = answers.sort_by {|a| a.question.order }
      hsh.merge section => sorted_answers
    end
  end

  def section_started?(section)
    !answers_to_section(section).empty?
  end

  def status_of_section(section, treat_no_mandatory_as_complete_instead_of_not_started=false)
    if section_started?(section)
      answers = all_answers_for_section(section)

      all_mandatory_questions_answered = all_mandatory_passed(answers)

      any_warnings = answers.map{|a| a.warnings.present?}.any?
      any_fatal_warnings = answers.map{|a| a.fatal_warnings.present?}.any?

      if all_mandatory_questions_answered
        if any_fatal_warnings
          INCOMPLETE
        elsif any_warnings
          COMPLETE_WITH_WARNINGS
        else
          COMPLETE
        end
      else
        INCOMPLETE
      end
    elsif treat_no_mandatory_as_complete_instead_of_not_started and all_mandatory_passed(all_answers_for_section(section))
      COMPLETE
    else
      NOT_STARTED
    end
  end

  def build_answers_from_hash(hash)
    hash.each do |question_code, answer_text|
      question = survey.questions.where(code: question_code).first
      if question && !answer_text.blank?
        answer = answers.build(question: question, response: self)
        answer.answer_value = answer_text
      end
    end
  end

  def status
    statii_of_sections = survey.sections.map{|s| status_of_section(s, :complete_if_no_mandatory) }

    if statii_of_sections.all? {|status| status == NOT_STARTED}
      NOT_STARTED
    elsif statii_of_sections.include? INCOMPLETE or statii_of_sections.include? NOT_STARTED
      INCOMPLETE
    elsif statii_of_sections.include? COMPLETE_WITH_WARNINGS
      COMPLETE_WITH_WARNINGS
    else
      COMPLETE
    end
  end

  def fatal_warnings?
    violates_mandatory || answers.collect(&:has_fatal_warning?).any?
  end

  def warnings?
    violates_mandatory || answers.collect(&:has_warning?).any?
  end

  def missing_mandatory_questions
    Question.find(missing_mandatory_question_ids)
  end

  private

  def all_mandatory_passed(answers)
    all_mandatory_questions_answered = answers.all?{|a| !a.violates_mandatory}
  end

  def all_answers_for_section(section)
    prepare_answers_to_section(section).values
  end

  def answers_to_section(section)
    answers.joins(:question).merge(Question.for_section(section))
  end

  def violates_mandatory
    !missing_mandatory_question_ids.empty?
  end

  def missing_mandatory_question_ids
    required_question_ids = survey.questions.where(:mandatory => true).collect(&:id)
    answered_question_ids = answers.collect(&:question_id)
    required_question_ids - answered_question_ids
  end

end
