class Survey < ActiveRecord::Base
  has_many :responses
  has_many :sections

  def ordered_questions
    Question.joins(section: :survey).where(sections: {survey_id: id}).order('sections."order"', '"order"')
  end
end
