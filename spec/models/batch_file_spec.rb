require 'spec_helper'

describe BatchFile do
  describe "Associations" do
    it { should belong_to(:user) }
    it { should belong_to(:survey) }
  end

  describe "Validations" do
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:survey_id) }
  end
end
