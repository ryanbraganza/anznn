class Survey < ActiveRecord::Base
  has_many :responses, dependent: :destroy
  has_many :sections, dependent: :destroy
  
  #TODO - this will be used to select 'active' surveys if that is required.
  # It is used in the 'new reponse' form, so currently it just returns all of them
  scope :active, order(:name)

  validates :name, presence: true

  def ordered_questions
    Question.joins(section: :survey).where(sections: {survey_id: id}).order('sections."order"', '"order"')
  end
  


  #TODO - thoughts?
  def destroy
    if Rails.env.development? or Rails.env.test?
      super
    else
      raise "Can't destroy surveys in production! \n" +
            "Destroying a survey would destroy *all* of the questions and answers that have been associated with it."
    end
  end
  
end