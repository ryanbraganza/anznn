class Question < ActiveRecord::Base
  belongs_to :section
  has_many :answers, dependent: :destroy
  has_many :question_options, dependent: :destroy

  validates_presence_of :order
  validates_presence_of :section
  validates_presence_of :question
  validates_presence_of :question_type
  validates_presence_of :code

  validates_uniqueness_of :order, scope: :section_id

  validates_inclusion_of :question_type, in: %w(Text Date Time Choice Decimal Integer)

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
end
