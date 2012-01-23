require 'spec_helper'

describe Question do
  describe "Associations" do
    it { should belong_to :section }
    it { should have_many :answers }
    it { should have_many :question_options }
  end

  describe "Validations" do
    describe "order" do
      it { should validate_presence_of :order }
      it "should validate that order is unique within a section" do
        first_q = Factory(:question)
        #should validate_uniqueness_of(:order).scoped_to :section_id
        second_q = Factory.build(:question, section: first_q.section, order: first_q.order)
        second_q.should_not be_valid
        diff_sec_q = Factory.build(:question, section: Factory(:section), order: first_q.order)
        diff_sec_q.should be_valid
      end
    end
    it { should validate_presence_of :section }
    it { should validate_presence_of :question }
  end
end
