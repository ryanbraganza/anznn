class ConfigurationItem < ActiveRecord::Base

  YEAR_OF_REGISTRATION_START = "YearOfRegStart"
  YEAR_OF_REGISTRATION_END = "YearOfRegEnd"

  validates_presence_of(:name)
  validates_presence_of(:configuration_value)

  def self.year_of_registration_range
    start = ConfigurationItem.find_by_name!(YEAR_OF_REGISTRATION_START).configuration_value.to_i
    finish = ConfigurationItem.find_by_name!(YEAR_OF_REGISTRATION_END).configuration_value.to_i
    (start..finish).to_a
  end
end
