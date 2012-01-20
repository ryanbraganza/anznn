class Question < ActiveRecord::Base
  belongs_to :section
  has_many :answers

  validates_presence_of :section
  validates_presence_of :question
end
