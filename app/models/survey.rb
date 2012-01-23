class Survey < ActiveRecord::Base
  has_many :responses
  has_many :sections
  
  #TODO - this will be used to select 'active' surveys if that is required.
  # It is used in the 'new reponse' form, so currently it just returns all of them
  scope :active, all


  validates :name, presence: true


  def ordered_questions
    Question.joins(section: :survey).where(sections: {survey_id: id}).order('sections."order"', '"order"')
  end
end
