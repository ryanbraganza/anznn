class Hospital < ActiveRecord::Base

  has_many :users
  has_many :responses

  validates_presence_of :name
  validates_presence_of :state
  validates_presence_of :abbrev
  validates_inclusion_of :state,
                         in: %w(ACT NSW Qld SA NT Vic WA North\ Island South\ Island),
                         message: "Sate %s is not a valid Aus/NZ state or territory"

end
