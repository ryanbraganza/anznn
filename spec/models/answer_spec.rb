require 'spec_helper'

describe Answer do
  describe "Associations" do
    it { should belong_to :question }
    it { should belong_to :response }
  end
  describe "Validations" do
    it { should validate_presence_of :question }
    it { should validate_presence_of :response }
  end
end
