class Hospital < ActiveRecord::Base

  ValidStates = %w(NSW Vic Qld SA Tas WA NT ACT North\ Island South\ Island)

  has_many :users
  has_many :responses

  validates_presence_of :name
  validates_presence_of :state
  validates_presence_of :abbrev
  validates_inclusion_of :state,
                         in: ValidStates,
                         message: "Sate %{value} is not a valid Aus/NZ state or territory"

  def self.all_states
    ValidStates
  end

  #define in_<state> 'scopes' for each state.
  # All lowercase, spaces -> '_'
  # Examples:
  #  collect all nsw hospitals by using 'Hospital.in_nsw'
  #  all north island hospitals - 'Hospital.in_north_island'
  ValidStates.each do |state|
    send :define_singleton_method, "in_#{state.gsub(' ', '_').downcase}" do
      where(state: state)
    end
  end


  def self.hospitals_by_state
    groups = Hash.new
    ValidStates.each do |state|
      hospitals = where(state: state).order(:name)
      mapped_hospitals = hospitals.collect do |h|
        [h.name, h.id]
      end
      groups[state] = mapped_hospitals
    end
    groups
  end



end
