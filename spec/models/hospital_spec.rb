require 'spec_helper'


describe Hospital do
  describe "Associations" do
    it { should have_many(:users) }
    it { should have_many(:responses) }
  end

  describe "Validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:state) }
    it { should validate_presence_of(:abbrev) }


    it "should ensure the state is a valid ANZ state" do
      pending
    end
  end


end
