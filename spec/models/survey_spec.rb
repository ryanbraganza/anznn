require 'spec_helper'

describe Survey do
  describe "Associations" do
    it { should have_many :responses }
    it { should have_many :sections }
  end
  describe "Validations" do
    before :each do
      Factory :survey
    end
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  describe :ordered_questions do
    it "should retrieve questions ordered by section.order, question.order" do
      survey = Factory(:survey)
      s2 = Factory(:section, survey: survey, section_order: 2)
      s1 = Factory(:section, survey: survey, section_order: 1)
      q1b = Factory(:question, question: 'q1b', section: s1, question_order: 2)
      q1a = Factory(:question, question: 'q1a', section: s1, question_order: 1)
      q2a = Factory(:question, question: 'q2a', section: s2, question_order: 1)
      q2b = Factory(:question, question: 'q2b', section: s2, question_order: 2)

      expected = %w{q1a q1b q2a q2b}
      actual = survey.ordered_questions.map { |q| q.question }

      actual.should eq expected
    end
  end

  describe "Finding the next section after a given section" do
    it "should find the next one based on order" do
      survey1 = Factory(:survey)
      sec2 = Factory(:section, survey: survey1, section_order: 2)
      sec3 = Factory(:section, survey: survey1, section_order: 3)
      sec1 = Factory(:section, survey: survey1, section_order: 1)

      survey1.section_id_after(sec1.id).should eq(sec2.id)
      survey1.section_id_after(sec2.id).should eq(sec3.id)
    end

    it "should raise error on last section" do
      survey1 = Factory(:survey)
      sec2 = Factory(:section, survey: survey1, section_order: 2)
      sec3 = Factory(:section, survey: survey1, section_order: 3)
      sec1 = Factory(:section, survey: survey1, section_order: 1)

      lambda { survey1.section_id_after(sec3.id) }.should raise_error("Tried to call section_id_after on last section")
    end

    it "should raise error when section not found" do
      survey1 = Factory(:survey)
      sec2 = Factory(:section, survey: survey1, section_order: 2)
      sec1 = Factory(:section, survey: survey1, section_order: 1)

      lambda { survey1.section_id_after(123434) }.should raise_error("Didn't find any section with id 123434 in this survey")
    end
  end

  describe "Get question with code" do
    before(:each) do
      @survey = Factory(:survey)
      @q1 = Factory(:question, code: 'qOne', section: Factory(:section, survey: @survey))
      @q2 = Factory(:question, code: 'QTwo', section: Factory(:section, survey: @survey))
      other_q1 = Factory(:question, code: 'qOne')
    end

    it "should find the question, even with mismatching case" do
      @survey.question_with_code("qOne").should eq(@q1)
      @survey.question_with_code("QOne").should eq(@q1)
      @survey.question_with_code("QonE").should eq(@q1)
    end

    it "should return the same object when asking twice" do
      q = @survey.question_with_code("qOne")
      @survey.question_with_code("qOne").should be(q)
    end

    it "should return nil if no such question exists in the survey" do
      @survey.question_with_code("blah").should be_nil
    end
  end


end
