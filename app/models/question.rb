class Question < ActiveRecord::Base
  belongs_to :section
  has_many :answers
  has_many :question_options

  validates_presence_of :order
  validates_presence_of :section
  validates_presence_of :question

  validates_uniqueness_of :order, scope: :section_id
end
