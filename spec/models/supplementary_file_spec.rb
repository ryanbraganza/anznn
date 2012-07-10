require 'spec_helper'

describe SupplementaryFile do
  describe "Associations" do
    it { should belong_to(:batch_file) }
  end

  describe "Validations" do
    it { should validate_presence_of(:multi_name) }
  end
end
