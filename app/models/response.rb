class Response < ActiveRecord::Base
  belongs_to :survey
  belongs_to :user
  has_many :answers, dependent: :destroy

  validates_presence_of :baby_code
  validates_presence_of :user
  validates_presence_of :survey

  def question_id_to_answers
    answers.reduce({}) do |hash, answer|
      hash[answer.question_id] =
          begin
            q_type = answer.question.question_type.downcase
            eval "answer.#{q_type}_answer"
          rescue NoMethodError
            nil
          end
      #Rails.logger.debug "Qn #{answer.question_id}: #{hash[answer.question_id]}"
      hash
    end
  end
end
