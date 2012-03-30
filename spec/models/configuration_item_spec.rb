require 'spec_helper'

describe ConfigurationItem do
  describe "Validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:configuration_value) }
  end
  
  describe "Get year of registration range" do
    it "should get the start and end years from the config table" do
      Factory(:configuration_item, name: ConfigurationItem::YEAR_OF_REGISTRATION_START, configuration_value: "2005")
      Factory(:configuration_item, name: ConfigurationItem::YEAR_OF_REGISTRATION_END, configuration_value: "2012")
      
      ConfigurationItem.year_of_registration_range.should eq((2005..2012).to_a)
    end
  end
end
