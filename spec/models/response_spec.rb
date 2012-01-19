require 'spec_helper'

describe Response do
  describe "Associations" do
    it { should belong_to :survey }
    it { should belong_to :user }
    it { should have_many :answers }
  end
end
