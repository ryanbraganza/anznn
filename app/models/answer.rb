class Answer < ActiveRecord::Base
  belongs_to :question
  belongs_to :response

  validates_presence_of :question
  validates_presence_of :response
end
