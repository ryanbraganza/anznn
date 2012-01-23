class QuestionOption < ActiveRecord::Base
  belongs_to :question

  validates_presence_of :question_id
  validates_presence_of :option_value
  validates_presence_of :label
  validates_presence_of :option_order
  validates_uniqueness_of :option_order, scoped_to: :question_id

end
