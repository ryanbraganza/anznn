class Answer < ActiveRecord::Base
  belongs_to :response
  belongs_to :question
end
