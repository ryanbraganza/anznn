class Survey < ActiveRecord::Base
  has_many :responses, dependent: :destroy
  has_many :sections, dependent: :destroy, order: '"order"'
  has_many :questions, through: :sections
  
  scope :by_name, order(:name)

  validates :name, presence: true

  def ordered_questions
    Question.joins(section: :survey).where(sections: {survey_id: id}).order('sections."order"', '"order"')
  end

  # find the next section after the section with the given id
  def section_id_after(section_id)
    section_ids = sections.collect(&:id)
    current_index = section_ids.index(section_id)
    raise "Didn't find any section with id #{section_id} in this survey" unless current_index
    raise "Tried to call section_id_after on last section" if current_index == (section_ids.size - 1)
    section_ids[current_index + 1]
  end

  def destroy
    # This is here as a safety measure, if we implement delete, it will need to be removed.
    if Rails.env.development? or Rails.env.test?
      super
    else
      raise "Can't destroy surveys in production! \n" +
            "Destroying a survey would destroy *all* of the questions and answers that have been associated with it."
    end
  end
  
end