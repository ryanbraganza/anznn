class Section < ActiveRecord::Base
  belongs_to :survey
  has_many :questions, dependent: :destroy, order: '"order"'

  validates_presence_of :name
  validates_presence_of :order
  validates_uniqueness_of :order, scope: :survey_id

  def last?
    section_orders = survey.sections.collect(&:order).sort
    self.order == section_orders.last
  end

end
