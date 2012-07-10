require 'spec_helper'

describe SupplementaryFile do
  describe "Associations" do
    it { should belong_to(:batch_file) }
  end
end
