class Response < ActiveRecord::Base
  belongs_to :survey
  belongs_to :user
  has_many :answers, dependent: :destroy

  validates_presence_of :baby_code
  validates_presence_of :user
  validates_presence_of :survey

  def question_id_to_answers
    answers.reduce({}) { |hash, answer| hash[answer.question_id] = answer; hash }
  end
end
