class Hospital < ActiveRecord::Base

  VALID_STATES = %w(NSW Vic Qld SA Tas WA NT ACT North\ Island South\ Island)

  has_many :users
  has_many :responses

  validates_presence_of :name
  validates_presence_of :state
  validates_presence_of :abbrev
  validates_inclusion_of :state,
                         in: VALID_STATES,
                         message: "State %{value} is not a valid Aus/NZ state or territory"

  def self.all_states
    VALID_STATES
  end

  def self.hospitals_by_state
    groups = Hash.new
    VALID_STATES.each do |state|
      hospitals = where(state: state).order(:name)
      mapped_hospitals = hospitals.collect do |h|
        [h.name, h.id]
      end
      groups[state] = mapped_hospitals
    end
    groups
  end



end
