require 'spec_helper'

describe Section do
  describe "Associations" do
    it { should belong_to :survey }
    it { should have_many :questions }
  end
end
