class Section < ActiveRecord::Base
  belongs_to :survey
  has_many :questions, dependent: :destroy, order: :question_order

  validates_presence_of :name
  validates_presence_of :section_order
  validates_uniqueness_of :section_order, scope: :survey_id

  def last?
    section_orders = survey.sections.collect(&:section_order).sort
    self.section_order == section_orders.last
  end

end
