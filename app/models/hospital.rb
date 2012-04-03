class Hospital < ActiveRecord::Base

  has_many :users
  has_many :responses

  validates_presence_of :name
  validates_presence_of :state
  validates_presence_of :abbrev

  def self.hospitals_by_state
    hospitals = order(:name).all
    grouped = hospitals.group_by(&:state)
    output = grouped.collect { |state, hospitals| [state, hospitals.collect { |h| [h.name, h.id] }] }
    output.sort { |a, b| a[0] <=> b[0] }
  end

end
