require 'spec_helper'

describe Answer do
  describe "Associations" do
    it { should belong_to :response }
    it { should belong_to :question }
  end
end
