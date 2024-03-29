class Question < ActiveRecord::Base

  TYPE_CHOICE = 'Choice'
  TYPE_DATE = 'Date'
  TYPE_DECIMAL = 'Decimal'
  TYPE_INTEGER = 'Integer'
  TYPE_TEXT = 'Text'
  TYPE_TIME = 'Time'

  belongs_to :section
  has_many :answers, dependent: :destroy
  has_many :cross_question_validations, dependent: :destroy
  has_many :question_options, dependent: :destroy, order: 'option_order'

  validates_presence_of :question_order
  validates_presence_of :section
  validates_presence_of :question
  validates_presence_of :question_type
  validates_presence_of :code

  validates_uniqueness_of :question_order, scope: :section_id

  validates_inclusion_of :question_type, in: [TYPE_CHOICE, TYPE_DATE, TYPE_DECIMAL, TYPE_INTEGER, TYPE_TEXT, TYPE_TIME]

  validates_numericality_of :number_min, allow_blank: true
  validates_numericality_of :number_max, allow_blank: true
  validates_numericality_of :number_unknown, allow_blank: true, only_integer: true

  validates_numericality_of :string_min, allow_blank: true, only_integer: true
  validates_numericality_of :string_max, allow_blank: true, only_integer: true

  def validate_number_range?
    !number_min.nil? || !number_max.nil?
  end

  def validate_string_length?
    !string_min.nil? || !string_max.nil?
  end

  def type_text?
    question_type == TYPE_TEXT
  end

  def type_integer?
    question_type == TYPE_INTEGER
  end

  def type_decimal?
    question_type == TYPE_DECIMAL
  end

  def type_choice?
    question_type == TYPE_CHOICE
  end

  def type_date?
    question_type == TYPE_DATE
  end

  def type_time?
    question_type == TYPE_TIME
  end

  def self.group_names_by_survey
    questions = where(multiple: true).includes(:section).order("sections.section_order, questions.question_order")
    by_survey = questions.group_by{ |q| q.section.survey_id }
    by_survey.each do |survey_id, questions|
      questions.map! { |question| question.multi_name }
      questions.uniq!
      questions.sort!
    end
    by_survey
  end

end
