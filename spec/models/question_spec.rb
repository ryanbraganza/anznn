require 'spec_helper'

describe Question do
  describe "Associations" do
    it { should belong_to :section }
    it { should have_many :answers }
  end
  describe "Validations" do
    describe "order" do
      it { should validate_presence_of :order }
      it "is unique within a section" do
        first_q = Factory(:question)
        #should validate_uniqueness_of(:order).scoped_to :section_id
        second_q = Factory.build(:question, section: first_q.section, order: first_q.order)
        second_q.should_not be_valid
      end
    end
    it { should validate_presence_of :section }
    it { should validate_presence_of :question }
  end
end
