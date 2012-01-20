class Question < ActiveRecord::Base
  belongs_to :section
  has_many :answers

  validates_presence_of :order
  validates_presence_of :section
  validates_presence_of :question

  validates_uniqueness_of :order, scoped_to: :section_id
end
