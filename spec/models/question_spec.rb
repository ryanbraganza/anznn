require 'spec_helper'

describe Question do
  describe "Associations" do
    it { should belong_to :section }
    it { should have_many :answers }
  end
  describe "Validations" do
    it { should validate_presence_of :section }
    it { should validate_presence_of :question }
  end
end
