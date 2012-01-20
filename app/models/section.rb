class Section < ActiveRecord::Base
  belongs_to :survey
  has_many :questions

  validates_presence_of :order
  validates_uniqueness_of :order, scoped_to: :survey_id

end
