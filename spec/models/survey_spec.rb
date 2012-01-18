require 'spec_helper'

describe Survey do
  describe "Associations" do
    it { should have_many :responses }
    it { should have_many :sections }
  end
end
