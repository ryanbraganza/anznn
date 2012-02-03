class QuestionOption < ActiveRecord::Base
  belongs_to :question

  validates_presence_of :question_id
  validates_presence_of :option_value
  validates_presence_of :label
  validates_presence_of :option_order
  validates_uniqueness_of :option_order, scope: :question_id

  def display_value
    "(#{option_value}) #{label}"
  end
end
