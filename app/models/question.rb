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
end
